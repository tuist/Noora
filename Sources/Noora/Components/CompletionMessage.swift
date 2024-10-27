import Foundation

public enum CompletionMessage {
    public enum Message {
        case error(message: String, context: String?, nextSteps: [String])
        case success(action: String)
        case warnings(_ warnings: [String])
    }

    public static func render(
        message: Message,
        theme: NooraTheme,
        environment: NooraEnvironment = .default,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async {
        switch message {
        case let .error(errorMessage, context, nextSteps):
            var content = """
            \("✘ An error ocurred".hexColorIfEnabled(theme.danger, environment: environment).bold)
            \(
                errorMessage.split(separator: "\n").map { "  \($0)".dimIfColorEnabled(environment: environment) }
                    .joined(separator: "\n")
            )
            """
            if let context {
                content = """
                \(content)

                \("  \("Context".underline)".hexColorIfEnabled(theme.danger, environment: environment))
                \(
                    context.split(separator: "\n").map { "    \($0)".dimIfColorEnabled(environment: environment) }
                        .joined(separator: "\n")
                )
                """
            }
            if !nextSteps.isEmpty {
                content = """
                \(content)

                \("  \("Next steps".underline)".hexColorIfEnabled(theme.danger, environment: environment))
                \(nextSteps.map { "    ▪︎ \($0)".dimIfColorEnabled(environment: environment) }.joined(separator: "\n"))
                """
            }
            await standardPipelines.error.write(content: "\(content)\n")
        case let .success(action):
            let content = """
            \("✓ \(action) completed successfully".hexColorIfEnabled(theme.success, environment: environment).bold)
            """
            await standardPipelines.output.write(content: "\(content)\n")
        case let .warnings(warnings):
            let content = """
            \(
                "⚠︎ The following warnings were emitted and might require action:"
                    .hexColorIfEnabled(theme.accent, environment: environment).bold
            )
            \(warnings.map { "    ▪︎ \($0)" }.joined(separator: "\n"))
            }))
            """
            await standardPipelines.output.write(content: "\(content)\n")
        }
    }
}
