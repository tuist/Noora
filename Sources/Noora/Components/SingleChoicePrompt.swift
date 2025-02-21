import Foundation
import Rainbow

struct SingleChoicePrompt {
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

    func run<T: CustomStringConvertible & Equatable>(options: [T]) -> T {
        run(options: options.map { ($0, $0.description) })
    }

    func run<T: CaseIterable & CustomStringConvertible & Equatable>() -> T {
        run(options: Array(T.allCases).map { ($0, $0.description) })
    }

    // MARK: - Private

    private func run<T: Equatable>(options: [(T, String)]) -> T {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }
        var selectedOption: (T, String)! = options.first

        terminal.inRawMode {
            renderOptions(selectedOption: selectedOption, options: options)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case .returnKey:
                    return .abort
                case .kKey, .upArrowKey:
                    let currentIndex = options.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = options[(currentIndex - 1 + options.count) % options.count]
                    renderOptions(selectedOption: selectedOption, options: options)
                    return .continue
                case .jKey, .downArrowKey:
                    let currentIndex = options.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = options[(currentIndex + 1 + options.count) % options.count]
                    renderOptions(selectedOption: selectedOption, options: options)
                    return .continue
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(selectedOption: selectedOption)
        }

        return selectedOption.0
    }

    private func renderResult(selectedOption: (some Equatable, String)) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(question.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        content += " \(selectedOption.1)"
        renderer.render(
            ProgressStep.completionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }

    private func renderOptions<T: Equatable>(selectedOption: (T, String), options: [(T, String)]) {
        let titleOffset = title != nil ? "  " : ""

        let questions = options.map { option in
            if option == selectedOption {
                return "\(titleOffset)  \("❯".hex(theme.primary)) \(option.1)"
            } else {
                return "\(titleOffset)    \(option.1)"
            }
        }.joined(separator: "\n")

        var content = ""
        if let title {
            content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        content += "\(title != nil ? "\n" : "")\(titleOffset)\(question.formatted(theme: theme, terminal: terminal))"
        if let description {
            content +=
                "\n\(titleOffset)\(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }
        content += "\n\(questions)"
        content += "\n\(titleOffset)\("↑/↓/k/j up/down • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
