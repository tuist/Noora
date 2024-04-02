import Foundation

public class Renderer {
    
    private var lastRenderedContent: [String] = []
    
    init() {}
    
    private func eraseLines(_ lines: Int, stream: StandardOutputStreaming) {
        if lines == 0 { return }
        for index in 0...lines {
            eraseLine(stream: stream)
            if index < lastRenderedContent.count {
                moveCursorUp(stream: stream)
            }
        }
        moveCursorToBeginningOfLine(stream: stream)
    }

    func moveCursorUp(stream: StandardOutputStreaming) {
        stream.write(content: "\u{001B}[1A")
    }
    
    func moveCursorToBeginningOfLine(stream: StandardOutputStreaming) {
        stream.write(content: "\u{001B}[1G")
    }
    
    func eraseLine(stream: StandardOutputStreaming) {
        stream.write(content: "\u{001B}[2K")
    }
        
    
    public func render(_ input: String, stream: StandardOutputStreaming) {
        let lines = input.split(separator: "\n")
        
        eraseLines(lastRenderedContent.count, stream: stream)

        lines.forEach { line in
            stream.write(content: String("\(line)\n"))
        }
        
        lastRenderedContent = lines.map { String($0) }
    }
}
