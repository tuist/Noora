import Foundation

public struct Renderer {
    private var lastRenderedContent: [String] = []

    init() {}

    private func eraseLines(_ lines: Int, standardPipeline: StandardPipelining) {
        if lines == 0 { return }
        for index in 0 ... lines {
            eraseLine(standardPipeline: standardPipeline)
            if index < lastRenderedContent.count {
                moveCursorUp(standardPipeline: standardPipeline)
            }
        }
        moveCursorToBeginningOfLine(standardPipeline: standardPipeline)
    }

    func moveCursorUp(standardPipeline: StandardPipelining) {
        standardPipeline.write(content: "\u{001B}[1A")
    }

    func moveCursorToBeginningOfLine(standardPipeline: StandardPipelining) {
        standardPipeline.write(content: "\u{001B}[1G")
    }

    func eraseLine(standardPipeline: StandardPipelining) {
        standardPipeline.write(content: "\u{001B}[2K")
    }

    public mutating func render(_ input: String, standardPipeline: StandardPipelining) {
        let lines = input.split(separator: "\n")

        eraseLines(lastRenderedContent.count, standardPipeline: standardPipeline)

        for line in lines {
            standardPipeline.write(content: String("\(line)\n"))
        }

        lastRenderedContent = lines.map { String($0) }
    }
}
