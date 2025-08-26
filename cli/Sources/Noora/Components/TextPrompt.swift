import Foundation
import Logging
import Rainbow

struct TextPrompt {
    let title: TerminalText?
    let prompt: TerminalText
    let description: TerminalText?
    let theme: Theme
    let content: Content
    let terminal: Terminaling
    let collapseOnAnswer: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let logger: Logger?
    let validationRules: [ValidatableRule]
    let validator: InputValidating

    func run() -> String {
        run(errors: [])
    }

    private func run(errors: [ValidatableError] = []) -> String {
        if !terminal.isInteractive {
            fatalError("'\(prompt)' can't be prompted in a non-interactive session.")
        }

        var input = ""

        terminal.withoutCursor {
            render(input: input, errors: errors)
            while let character = terminal.readCharacter(), character != "\n" {
                if character == "\u{08}" || character == "\u{7F}" { // Handle Backspace (Delete Last Character)
                    if !input.isEmpty {
                        input.removeLast() // Remove last character from input
                    }
                } else {
                    input.append(character)
                }
                render(input: input)
            }
        }

        logger?.debug("Prompted '\(prompt.plain())'")

        let validationResult = validator.validate(input: input, rules: validationRules)

        switch validationResult {
        case .success:
            render(input: input, withCursor: false)
        case let .failure(error):
            return run(errors: error.errors)
        }

        renderResult(input: input)

        logger?.debug("Responded \(input) to prompt '\(prompt.plain())'")

        return input
    }

    private func render(input: String, withCursor: Bool = true, errors: [ValidatableError] = []) {
        let titleOffset = title != nil ? "  " : ""

        var message = ""
        if let title {
            message = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let input = "\(input)\(withCursor ? "█" : "")".hexIfColoredTerminal(theme.secondary, terminal)

        message += "\(title != nil ? "\n" : "")\(titleOffset)\(prompt.formatted(theme: theme, terminal: terminal)) \(input)"

        if !errors.isEmpty {
            var errorMessage = "\(content.textPromptValidationErrorsTitle):\n\(titleOffset)"

            errorMessage += errors
                .map { "· \($0.message)" }
                .joined(separator: "\n\(titleOffset)")

            message +=
                "\n\(titleOffset)\(TerminalText(stringLiteral: errorMessage).formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.danger, terminal))"
        }

        if let description {
            message +=
                "\n\(titleOffset)\(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }

        renderer.render(message, standardPipeline: standardPipelines.output)
    }

    private func renderResult(input: String) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(prompt.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        content += " \(input)"
        renderer.render(
            .progressCompletionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }
}
