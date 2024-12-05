import Foundation
import Rainbow

struct SingleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable> {
    // MARK: - Attributes

    let title: String?
    let question: String
    let description: String?
    let options: T.Type
    let theme: NooraTheme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening
    var filtering: Bool = false

//    init(
//        title: String?,
//        question: String,
//        description: String?,
//        options: T.Type,
//        collapseOnSelection: Bool = true,
//        theme: NooraTheme,
//        terminal: Terminaling = Terminal.current()!,
//        renderer: Rendering = Renderer(),
//        standardPipelines: StandardPipelines = StandardPipelines(),
//        keyStrokeListener: KeyStrokeListening = KeyStrokeListener()
//    ) {
//        self.title = title
//        self.question = question
//        self.description = description
//        self.options = options
//        self.theme = theme
//        self.terminal = terminal
//        self.collapseOnSelection = collapseOnSelection
//        self.keyStrokeListener = keyStrokeListener
//        self.standardPipelines = standardPipelines
//        self.renderer = renderer
//    }

    func run() -> T {
        let allOptions = Array(T.allCases)
        var selectedOption: T! = allOptions.first

        terminal.inRawMode {
            renderOptions(selectedOption: selectedOption)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case .qKey, .returnKey:
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
            "\(title):".hexIfColoredTerminal(theme.primary, terminal: terminal).boldIfColoredTerminal(terminal)
        } else {
            "\(question):".hexIfColoredTerminal(theme.primary, terminal: terminal).boldIfColoredTerminal(terminal)
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
        var content = if let title {
            title.hexIfColoredTerminal(theme.primary, terminal: terminal).boldIfColoredTerminal(terminal)
        } else {
            ""
        }

        content += "\n  \(question)"
        if let description {
            content += "\n  \(description.hexIfColoredTerminal(theme.muted, terminal: terminal))"
        }
        content += "\n\(questions)"
        content += "\n  \("↑/↓/k/j up/down • enter confirm".hexIfColoredTerminal(theme.muted, terminal: terminal))"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
