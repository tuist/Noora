import Foundation

public enum CompletionMessage {
    public enum Message {
        case error(message: String, context: String?, nextSteps: [String])
        case success(action: String)
        case warnings(_ warnings: [String])
    }

    public static func render(message: Message, theme: Theme, standardPipelines: StandardPipelines = StandardPipelines()) async {
        switch message {
        case let .error(errorMessage, context, nextSteps):
            var content = """
            \("✘ An error ocurred".hexColorIfEnabled(theme.danger).bold)
            \(errorMessage.split(separator: "\n").map { "  \($0)" }.joined(separator: "\n"))
            """
            if let context = context {
            content = """
            \(content)
            
            \("  \("Context".underline)".hexColorIfEnabled(theme.danger))
            \(context.split(separator: "\n").map { "    \($0)" }.joined(separator: "\n"))
            """
            }
            if !nextSteps.isEmpty {
            content = """
            \(content)
            
            \("  \("Next steps".underline)".hexColorIfEnabled(theme.danger))
            \(nextSteps.map { "    ▪︎ \($0)" }.joined(separator: "\n"))
            """
            }
            await standardPipelines.error.write(content: "\(content)\n")
        case let .success(action):
            let content = """
            \("✓ \(action.localizedCapitalized) completed successfully".hex(theme.success).bold)
            """
            await standardPipelines.output.write(content: "\(content)\n")
        case let .warnings(warnings):
            let content = """
            \("⚠︎ The following warnings were emitted and might require action:".hex(theme.accent).bold)
            \(warnings.map { "    ▪︎ \($0)" }.joined(separator: "\n"))
            }))
            """
            await standardPipelines.output.write(content: "\(content)\n")
        }
    }
}
