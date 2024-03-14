import Foundation

public protocol Rendering: Actor {
    func render(_ content: String, stream: StandardOutputStreaming) throws
    func render(_ content: String) throws
}

public actor Renderer: Rendering {
    private var lastRenderedContent: [String] = []
    
    public init() {}

    public func render(_ content: String) throws {
        try render(content, stream: StandardOutputStream.output)
    }

    public func render(_ content: String, stream: StandardOutputStreaming) throws {
        let lines = content.split(separator: "\n")
        
        try eraseLines(lastRenderedContent.count, stream: stream)

        try lines.forEach { line in
            try stream.write(content: String("\(line)\n"))
        }
        
        lastRenderedContent = lines.map { String($0) }
    }
    
    private func eraseLines(_ lines: Int, stream: StandardOutputStreaming) throws {
        if lines == 0 { return }
        for index in 0...lines {
            try eraseLine(stream: stream)
            if index < lastRenderedContent.count {
                try moveCursorUp(stream: stream)
            }
        }
        try moveCursorToBeginningOfLine(stream: stream)
    }

    func moveCursorUp(stream: StandardOutputStreaming) throws {
        try stream.write(content: "\u{001B}[1A")
    }
    
    func moveCursorToBeginningOfLine(stream: StandardOutputStreaming) throws {
        try stream.write(content: "\u{001B}[1G")
    }
    
    func eraseLine(stream: StandardOutputStreaming) throws {
        try stream.write(content: "\u{001B}[2K")
    }
}
