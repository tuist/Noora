import Foundation
import Logging
import Rainbow

struct TextPrompt {
    let title: TerminalText?
    let prompt: TerminalText
    let description: TerminalText?
    let defaultValue: String?
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

        func isReturn(_ character: Character) -> Bool {
            #if os(Windows)
                return character.unicodeScalars.first?.value == 10 || character.unicodeScalars.first?.value == 13
            #else
                return character == "\n"
            #endif
        }

        terminal.withoutCursor {
            render(input: input, errors: errors)
            while let character = terminal.readCharacter(), !isReturn(character) {
                #if os(Windows)
                    // Handle Ctrl+C (character code 3)
                    // On Windows, Ctrl+C generates character code 3
                    // while "getch" is running it doesn't emit a signal
                    if character.unicodeScalars.first?.value == 3 {
                        exit(0)
                    }

                    let isBackspace = character.unicodeScalars.first?.value == 8 || character.unicodeScalars.first?.value == 127
                #else
                    let isBackspace = character == "\u{08}" || character == "\u{7F}"
                #endif
                if isBackspace { // Handle Backspace (Delete Last Character)
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

        let resolvedInput: String
        if input.isEmpty, let defaultValue {
            resolvedInput = defaultValue
        } else {
            resolvedInput = input
        }

        let validationResult = validator.validate(input: resolvedInput, rules: validationRules)

        switch validationResult {
        case .success:
            render(input: input, withCursor: false)
        case let .failure(error):
            return run(errors: error.errors)
        }

        renderResult(input: resolvedInput)

        logger?.debug("Responded \(resolvedInput) to prompt '\(prompt.plain())'")

        return resolvedInput
    }

    private func render(input: String, withCursor: Bool = true, errors: [ValidatableError] = []) {
        let titleOffset = title != nil ? "  " : ""

        var message = ""
        if let title {
            message = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let inputDisplay = "\(input)\(withCursor ? "█" : "")".hexIfColoredTerminal(theme.secondary, terminal)

        message += "\(title != nil ? "\n" : "")\(titleOffset)\(prompt.formatted(theme: theme, terminal: terminal)) \(inputDisplay)"

        if input.isEmpty, let defaultValue, withCursor {
            let defaultHint = "Press Enter to use \(defaultValue)".hexIfColoredTerminal(theme.muted, terminal)
            message += "\n\(titleOffset)\(defaultHint)"
        }

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
