import Foundation

/// Rendering represents an interface to render content in the terminal.
/// Since renderer is stateful, holding the state of the last rendered output to be able to
/// render incrementally from it, there can only be one renderer active at the same time.
/// It's the consumer's responsibility to ensure only one component is rendering output.
public protocol Rendering: AnyObject {
    /// It renders some content in the terminal using the given standard pipeline.
    /// Consecutive calls to this function override the previous output, making it feel
    /// like an animation.
    /// - Parameters:
    ///   - input: The content to be output.
    ///   - standardPipeline: The standard pipeline through which to output.
    func render(_ input: String, standardPipeline: StandardPipelining)
}

public class Renderer: Rendering {
    private var lastRenderedContent: [String] = []

    public init() {}

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

    public func render(_ input: String, standardPipeline: StandardPipelining) {
        let lines = input.split(separator: "\n")

        eraseLines(lastRenderedContent.count, standardPipeline: standardPipeline)

        for line in lines {
            standardPipeline.write(content: String("\(line)\n"))
        }

        lastRenderedContent = lines.map { String($0) }
    }
}
