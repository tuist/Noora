import Foundation
import Logging
import Rainbow

struct YesOrNoChoicePrompt {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let theme: Theme
    let localization: Localization
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening
    let defaultAnswer: Bool
    let logger: Logger?

    func run() -> Bool {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }

        var answer: Bool = defaultAnswer

        logger?.debug("Prompted '\(question.plain())'")

        terminal.inRawMode {
            renderOptions(answer: answer)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case let .printable(character) where character == localization.yesOrNoChoicePromptPositiveText.character:
                    answer = true
                    return .abort
                case let .printable(character) where character == localization.yesOrNoChoicePromptNegativeText.character:
                    answer = false
                    return .abort
                case let .printable(character) where character == "l":
                    fallthrough
                case let .printable(character) where character == "h":
                    fallthrough
                case .leftArrowKey, .rightArrowKey:
                    answer = !answer
                    renderOptions(answer: answer)
                    return .continue
                case .returnKey:
                    return .abort
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(answer: answer)
        }

        logger?.debug("Responded \(answer ? "yes" : "no") to prompt '\(question.plain())'")

        return answer
    }

    // MARK: - Private

    private func renderResult(answer: Bool) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(question.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        content += " \(answer ? localization.yesOrNoChoicePromptPositiveText.fullText : localization.yesOrNoChoicePromptNegativeText.fullText)"

        renderer.render(
            .progressCompletionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }

    private func renderOptions(answer: Bool) {
        var content = ""
        if let title {
            content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let yesText = localization.yesOrNoChoicePromptPositiveText
        let noText = localization.yesOrNoChoicePromptNegativeText

        let yes = if answer {
            if terminal.isColored {
                " \(yesText.fullText) (\(yesText.character)) ".onHex(theme.secondary)
            } else {
                "[ \(yesText.fullText) (\(yesText.character)) ]"
            }
        } else {
            " \(yesText.fullText) (\(yesText.character)) "
        }

        let no = if answer {
            " \(noText.fullText) (\(noText.character)) "
        } else {
            if terminal.isColored {
                " \(noText.fullText) (\(noText.character)) ".onHex(theme.secondary)
            } else {
                "[ \(noText.fullText) (\(noText.character)) ]"
            }
        }

        content += "\n  \(question.formatted(theme: theme, terminal: terminal)) \(yes) / \(no)"
        if let description {
            content +=
                "\n  \(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }

        content += "\n  \(localization.yesOrNoChoicePromptInstruction.hexIfColoredTerminal(theme.muted, terminal))"

        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
