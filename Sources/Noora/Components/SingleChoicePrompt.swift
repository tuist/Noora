import Foundation
import Rainbow

struct SingleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable> {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let options: T.Type
    let theme: Theme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening

    func run() -> T {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }

        let allOptions = Array(T.allCases)
        var selectedOption: T! = allOptions.first

        terminal.inRawMode {
            renderOptions(selectedOption: selectedOption)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case .returnKey:
                    return .abort
                case .kKey, .upArrowKey:
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex - 1 + allOptions.count) % allOptions.count]
                    renderOptions(selectedOption: selectedOption)
                    return .continue
                case .jKey, .downArrowKey:
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex + 1 + allOptions.count) % allOptions.count]
                    renderOptions(selectedOption: selectedOption)
                    return .continue
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(selectedOption: selectedOption)
        }

        return selectedOption
    }

    // MARK: - Private

    private func renderResult(selectedOption: T) {
        var content = if let title {
            "\(title):".hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal)
        } else {
            "\(question):".hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal)
        }
        content += " \(selectedOption.description)"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }

    private func renderOptions(selectedOption: T) {
        let options = Array(options.allCases)

        let questions = options.map { option in
            if option == selectedOption {
                return "   \("❯".hex(theme.primary)) \(option.description)"
            } else {
                return "     \(option.description)"
            }
        }.joined(separator: "\n")
        var content = ""
        if let title {
            content = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        content += "\n  \(question)"
        if let description {
            content +=
                "\n  \(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }
        content += "\n\(questions)"
        content += "\n  \("↑/↓/k/j up/down • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
