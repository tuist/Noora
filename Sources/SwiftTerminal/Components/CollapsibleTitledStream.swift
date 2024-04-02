import Foundation
import Rainbow

public class CollapsibleTitledStream {
    
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
        
    @discardableResult public init(title: String, stream: AsyncThrowingStream<Event, Error>, streams: StandardStreams = StandardStreams()) async throws {
        try await self.render(title: title, stream: stream, streams: streams)
    }
    
    private func render(title: String, stream: AsyncThrowingStream<Event, Error>, streams: StandardStreams) async throws {
        if isTerminalInteractive() {
            try await renderInteractive(title: title, stream: stream, streams: streams)
        } else {
            try await renderNonInteractive(title: title, stream: stream, streams: streams)
        }
    }
    
    private func renderNonInteractive(title: String, stream: AsyncThrowingStream<Event, Error>, streams: StandardStreams) async throws {
        
        streams.output.write(content: "\(formatRunningPrefix("Running:")) \(title)\n")
        
        for try await event in stream {
            event.lines.forEach { line in
                streams.output.write(content: formatProgressLine(String("\(line)\n")))
            }
        }
        
        streams.output.write(content: "\(formatCompletedPrefix("Completed: ")) \(title)\n")
    }
    
    private func renderInteractive(title: String, stream: AsyncThrowingStream<Event, Error>, streams: StandardStreams) async throws {
        let renderer = Renderer()
        var stack = Stack<String>(["", "", ""], maximumCapacity: 3)
        var spinnerLastCharacter: String = ""

        func renderStack() {
            let lines = [
                stack.count >= 3 ? stack[2]! : "",
                stack.count >= 2 ? stack[1]! : "",
                stack.count >= 1 ? stack[0]! : ""
            ]
            let content = """
            \(lines.map({formatProgressLine("\($0)")}).joined(separator: "\n"))
            \(formatRunningPrefix("\(spinnerLastCharacter) Running: "))\(title)
            """
            renderer.render(content, stream: streams.output)
        }
        
        func onEvent(_ event: Event) {
            event.lines.forEach({ stack.push(String($0)) })
            renderStack()
        }
        
        let spinner = Spinner({ character in
            spinnerLastCharacter = character
            renderStack()
        })
        
        renderStack()
        
        for try await event in stream {
            onEvent(event)
        }
        
        renderer.render("\(formatCompletedPrefix("Completed: "))\(title)", stream: streams.output)
    }
    
    private func formatProgressLine(_ line: String) -> String {
        if shouldColorTerminalComponents() {
            "    \(line.dim)"
        } else {
            "    \(line)"
        }
    }
    
    private func formatRunningPrefix(_ line: String) -> String {
        if shouldColorTerminalComponents() {
            line.yellow.bold
        } else {
            line
        }
    }
    
    private func formatCompletedPrefix(_ line: String) -> String {
        if shouldColorTerminalComponents() {
            line.yellow.green
        } else {
            line
        }
    }
}
