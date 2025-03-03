import Foundation
import Logging
import Rainbow

struct TextPrompt {
    let title: TerminalText?
    let prompt: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnAnswer: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let logger: Logger?

    func run() -> String {
        if !terminal.isInteractive {
            logger?.error("\(prompt) was attempted to prompt in a non-interactive session")
            fatalError("'\(prompt)' can't be prompted in a non-interactive session.")
        }

        var input = ""

        terminal.withoutCursor {
            render(input: input)
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

        render(input: input, withCursor: false)

        renderResult(input: input)

        return input
    }

    private func render(input: String, withCursor: Bool = true) {
        let titleOffset = title != nil ? "  " : ""

        var content = ""
        if let title {
            content = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let input = "\(input)\(withCursor ? "█" : "")".hexIfColoredTerminal(theme.secondary, terminal)

        content += "\(title != nil ? "\n" : "")\(titleOffset)\(prompt.formatted(theme: theme, terminal: terminal)) \(input)"

        if let description {
            content +=
                "\n\(titleOffset)\(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }

        renderer.render(content, standardPipeline: standardPipelines.output)
        logger?.trace("A text prompt shown with content '\(content)' \(withCursor ? "with cursor" : " without cursor")")
    }

    private func renderResult(input: String) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(prompt.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        logger?.trace("A text prompt with content '\(content)' got input  \(input) selected")
        content += " \(input)"
        renderer.render(
            ProgressStep.completionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
        logger?.info(
            "A text prompt completion message is \(ProgressStep.completionMessage(content, theme: theme, terminal: terminal))"
        )
    }
}
