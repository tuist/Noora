import Foundation

public class TerminalErrorMessage {
    public static func render(message: String, context: String, nextSteps: [String], streams: StandardStreams = StandardStreams()) {
        let content = """
        \("✘ An error ocurred".bold.red)
        \(message.split(separator: "\n").map({"  \($0)"}).joined(separator: "\n"))
        
        \("  \("Context".underline)".red)
        \(context.split(separator: "\n").map({"    \($0)"}).joined(separator: "\n"))
        
        \("  \("Next steps".underline)".red)
        \(nextSteps.map({"    ▪︎ \($0)"}).joined(separator: "\n"))
        """
        
        streams.error.write(content: "\(content)\n")
    }
}
