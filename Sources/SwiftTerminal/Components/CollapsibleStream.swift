import Foundation
import Rainbow
import Asynchrone

public class CollapsibleStream {
    public enum Event {
        case output(String)
        case error(String)

        var lines: [Substring] {
            switch self {
            case let .error(content): return content.split(separator: "\n")
            case let .output(content): return content.split(separator: "\n")
            }
        }
    }

    public static func render(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async throws {
        try await CollapsibleStream(title: title, stream: stream, theme: theme, standardPipelines: standardPipelines)
    }

    @discardableResult private init(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async throws {
        try await render(title: title, stream: stream, theme: theme, standardPipelines: standardPipelines)
    }

    private func render(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        standardPipelines: StandardPipelines
    ) async throws {
        if isTerminalInteractive() {
            try await renderInteractive(title: title, stream: stream, theme: theme, standardPipelines: standardPipelines)
        } else {
            try await renderNonInteractive(title: title, stream: stream, theme: theme, standardPipelines: standardPipelines)
        }
    }

    private func renderNonInteractive(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        standardPipelines: StandardPipelines
    ) async throws {
        await standardPipelines.output.write(content: "\(formatRunningPrefix("Running:", theme: theme)) \(title)\n")

        for try await event in stream {
            for line in event.lines {
                await standardPipelines.output.write(content: formatProgressLine(String("\(line)\n")))
            }
        }

        await standardPipelines.output.write(content: "\(formatCompletedPrefix("Completed: ", theme: theme)) \(title)\n")
    }

    private func renderInteractive(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        standardPipelines: StandardPipelines
    ) async throws {
        let renderer = Renderer()
        var stack = Stack<String>(["", "", ""], maximumCapacity: 3)
        var spinnerLastCharacter = ""

        func renderStack() async {
            let lines = [
                stack.count >= 3 ? stack[2]! : "",
                stack.count >= 2 ? stack[1]! : "",
                stack.count >= 1 ? stack[0]! : "",
            ]
            let content = """
            \(lines.map { formatProgressLine("\($0)") }.joined(separator: "\n"))
            \(formatRunningPrefix("\(spinnerLastCharacter) Running: ", theme: theme))\(title)
            """
            await renderer.render(content, standardPipeline: standardPipelines.output)
        }

        func onEvent(_ event: Event) async {
            event.lines.forEach { stack.push(String($0)) }
            await renderStack()
        }

        let spinner = await Spinner { character in
            spinnerLastCharacter = character
            await renderStack()
        }

        await renderStack()

        for try await event in stream.throttle(for: 0.5, latest: true) {
            await onEvent(event)
        }

        await renderer.render(
            "\(formatCompletedPrefix("Completed: ", theme: theme))\(title)",
            standardPipeline: standardPipelines.output
        )
    }

    private func formatProgressLine(_ line: String) -> String {
        if shouldColorTerminalComponents() {
            "    \(line.dim)"
        } else {
            "    \(line)"
        }
    }

    private func formatRunningPrefix(_ line: String, theme: Theme) -> String {
        if shouldColorTerminalComponents() {
            line.hex(theme.secondary)
        } else {
            line
        }
    }

    private func formatCompletedPrefix(_ line: String, theme: Theme) -> String {
        if shouldColorTerminalComponents() {
            line.hex(theme.success)
        } else {
            line
        }
    }
}
