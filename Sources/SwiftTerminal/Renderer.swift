import Foundation

protocol Rendering: Actor {
    func render(_ content: String, stream: StandardOutputStreaming) throws
    func render(_ content: String) throws
}

actor Renderer: Rendering {
    private var lastRenderedContent: [String] = []

    func render(_ content: String) throws {
        try render(content, stream: StandardOutputStream.output)
    }

    func render(_ content: String, stream: StandardOutputStreaming) throws {
        try reset(stream: stream)
        let lines = content.split(separator: "\n")
        try lines.forEach { line in
            try stream.write(content: String(line))
        }
        lastRenderedContent = lines.map { String($0) }
    }

    func reset(stream: StandardOutputStreaming) throws {
        if lastRenderedContent.isEmpty { return }
        try moveCursorUp(times: lastRenderedContent.count, stream: stream)
        try moveCursorToBeginningOfTheLine(stream: stream)
        lastRenderedContent = []
    }

    func moveCursorToBeginningOfTheLine(stream: StandardOutputStreaming) throws {
        try stream.write(content: "\r")
    }

    func moveCursorUp(times: Int, stream: StandardOutputStreaming) throws {
        for _ in 0 ..< times {
            try stream.write(content: "\u{001B}[1A")
        }
    }
}
