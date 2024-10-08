import Asynchrone
import Foundation
import Rainbow

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
        environment: Environment = .default,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async throws {
        try await CollapsibleStream(
            title: title,
            stream: stream,
            theme: theme,
            environment: environment,
            standardPipelines: standardPipelines
        )
    }

    @discardableResult private init(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        environment: Environment = .default,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async throws {
        try await render(
            title: title,
            stream: stream,
            theme: theme,
            environment: environment,
            standardPipelines: standardPipelines
        )
    }

    private func render(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        environment: Environment = .default,
        standardPipelines: StandardPipelines
    ) async throws {
        if environment.isInteractive {
            try await renderInteractive(
                title: title,
                stream: stream,
                theme: theme,
                environment: environment,
                standardPipelines: standardPipelines
            )
        } else {
            try await renderNonInteractive(
                title: title,
                stream: stream,
                theme: theme,
                environment: environment,
                standardPipelines: standardPipelines
            )
        }
    }

    private func renderNonInteractive(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        environment: Environment = .default,
        standardPipelines: StandardPipelines
    ) async throws {
        await standardPipelines.output
            .write(content: "\(formatRunningPrefix("Running:", theme: theme, environment: environment)) \(title)\n")

        for try await event in stream {
            for line in event.lines {
                await standardPipelines.output.write(content: formatProgressLine(String("\(line)\n"), environment: environment))
            }
        }

        await standardPipelines.output
            .write(content: "\(formatCompletedPrefix("Completed: ", theme: theme, environment: environment)) \(title)\n")
    }

    private func renderInteractive(
        title: String,
        stream: AsyncThrowingStream<Event, Error>,
        theme: Theme,
        environment: Environment = .default,
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
            \(lines.map { formatProgressLine("\($0)", environment: environment) }.joined(separator: "\n"))
            \(formatRunningPrefix("\(spinnerLastCharacter) Running: ", theme: theme, environment: environment))\(title)
            """
            await renderer.render(content, standardPipeline: standardPipelines.output)
        }

        func onEvent(_ event: Event) async {
            event.lines.forEach { stack.push(String($0)) }
            await renderStack()
        }

        let cancelSpinner = await Spinner.spin { character in
            spinnerLastCharacter = character
            await renderStack()
        }

        defer {
            cancelSpinner()
        }

        await renderStack()

        var thrownError: Error?
        do {
            for try await event in stream.throttle(for: 0.2, latest: false) {
                await onEvent(event)
            }
        } catch {
            thrownError = error
        }

        if let thrownError {
            await renderer.render(
                "\(formatFailedPrefix("Failed: ", theme: theme, environment: environment))\(title)",
                standardPipeline: standardPipelines.output
            )
            throw thrownError
        } else {
            await renderer.render(
                "\(formatCompletedPrefix("Completed: ", theme: theme, environment: environment))\(title)",
                standardPipeline: standardPipelines.output
            )
        }
    }

    private func formatProgressLine(_ line: String, environment: Environment) -> String {
        if environment.shouldColor {
            "    \(line.dim)"
        } else {
            "    \(line)"
        }
    }

    private func formatRunningPrefix(_ line: String, theme: Theme, environment: Environment) -> String {
        if environment.shouldColor {
            line.hex(theme.secondary)
        } else {
            line
        }
    }

    private func formatCompletedPrefix(_ line: String, theme: Theme, environment: Environment) -> String {
        if environment.shouldColor {
            line.hex(theme.success)
        } else {
            line
        }
    }

    private func formatFailedPrefix(_ line: String, theme: Theme, environment: Environment) -> String {
        if environment.shouldColor {
            line.hex(theme.danger)
        } else {
            line
        }
    }
}
