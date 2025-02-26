import Foundation
import Rainbow

struct YesOrNoChoicePrompt {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening
    let defaultAnswer: Bool

    func run() -> Bool {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }

        var answer: Bool = defaultAnswer

        terminal.inRawMode {
            renderOptions(answer: answer)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case let .printable(character) where character == "y":
                    answer = true
                    return .abort
                case let .printable(character) where character == "n":
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
                case let .printable(character) where character.isNewline:
                    return .abort
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(answer: answer)
        }

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
        content += " \(answer ? "Yes" : "No")"

        renderer.render(
            ProgressStep.completionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }

    private func renderOptions(answer: Bool) {
        var content = ""
        if let title {
            content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let yes = if answer {
            if terminal.isColored {
                " Yes (y) ".onHex(theme.muted)
            } else {
                "[ Yes (y) ]"
            }
        } else {
            " Yes (y) "
        }

        let no = if answer {
            " No (n) "
        } else {
            if terminal.isColored {
                " No (n) ".onHex(theme.muted)
            } else {
                "[ No (n) ]"
            }
        }

        content += "\n  \(question.formatted(theme: theme, terminal: terminal)) \(yes) / \(no)"
        if let description {
            content +=
                "\n  \(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }
        content += "\n  \("←/→/h/l left/right • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
