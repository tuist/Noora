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
    let keyStrokeListener: KeyStrokeListening
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

        var input = [Character]()
        var cursorIndex = 0

        terminal.withoutCursor {
            render(input: String(input), cursorIndex: cursorIndex, errors: errors)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case .returnKey:
                    return .abort
                case let .printable(character):
                    input.insert(character, at: cursorIndex)
                    cursorIndex += 1
                case .backspace:
                    if cursorIndex > 0 {
                        cursorIndex -= 1
                        input.remove(at: cursorIndex)
                    }
                case .delete:
                    if cursorIndex < input.count {
                        input.remove(at: cursorIndex)
                    }
                case .leftArrowKey:
                    if cursorIndex > 0 {
                        cursorIndex -= 1
                    }
                case .rightArrowKey:
                    if cursorIndex < input.count {
                        cursorIndex += 1
                    }
                case .home:
                    cursorIndex = 0
                case .end:
                    cursorIndex = input.count
                default:
                    return .continue
                }
                render(input: String(input), cursorIndex: cursorIndex)
                return .continue
            }
        }

        logger?.debug("Prompted '\(prompt.plain())'")

        let resolvedInput: String
        if input.isEmpty, let defaultValue {
            resolvedInput = defaultValue
        } else {
            resolvedInput = String(input)
        }

        let validationResult = validator.validate(input: resolvedInput, rules: validationRules)

        switch validationResult {
        case .success:
            render(input: String(input), cursorIndex: cursorIndex, withCursor: false)
        case let .failure(error):
            return run(errors: error.errors)
        }

        renderResult(input: resolvedInput)

        logger?.debug("Responded \(resolvedInput) to prompt '\(prompt.plain())'")

        return resolvedInput
    }

    private func render(
        input: String,
        cursorIndex: Int = 0,
        withCursor: Bool = true,
        errors: [ValidatableError] = []
    ) {
        let titleOffset = title != nil ? "  " : ""

        var message = ""
        if let title {
            message = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let inputDisplay: String
        if withCursor {
            let prefix = String(input.prefix(cursorIndex))
            let suffix = String(input.dropFirst(cursorIndex))
            inputDisplay = "\(prefix)█\(suffix)".hexIfColoredTerminal(theme.secondary, terminal)
        } else {
            inputDisplay = input.hexIfColoredTerminal(theme.secondary, terminal)
        }

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
