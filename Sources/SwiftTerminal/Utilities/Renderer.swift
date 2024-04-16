import Foundation

public actor Renderer {
    private var lastRenderedContent: [String] = []

    init() {}

    private func eraseLines(_ lines: Int, standardPipeline: StandardPipelining) async {
        if lines == 0 { return }
        for index in 0 ... lines {
            await eraseLine(standardPipeline: standardPipeline)
            if index < lastRenderedContent.count {
                await moveCursorUp(standardPipeline: standardPipeline)
            }
        }
        await moveCursorToBeginningOfLine(standardPipeline: standardPipeline)
    }

    func moveCursorUp(standardPipeline: StandardPipelining) async {
        await standardPipeline.write(content: "\u{001B}[1A")
    }

    func moveCursorToBeginningOfLine(standardPipeline: StandardPipelining) async {
        await standardPipeline.write(content: "\u{001B}[1G")
    }

    func eraseLine(standardPipeline: StandardPipelining) async {
        await standardPipeline.write(content: "\u{001B}[2K")
    }

    public func render(_ input: String, standardPipeline: StandardPipelining) async {
        let lines = input.split(separator: "\n")

        await eraseLines(lastRenderedContent.count, standardPipeline: standardPipeline)

        for line in lines {
            await standardPipeline.write(content: String("\(line)\n"))
        }

        lastRenderedContent = lines.map { String($0) }
    }
}
