import Foundation
import Rainbow

class SingleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable> {
    // MARK: - Attributes

    private let title: String?
    private let question: String
    private let description: String?
    private let options: T.Type
    private let theme: NooraTheme
    private let terminal: Terminaling
    private let collapseOnSelection: Bool
    private let renderer: Rendering
    private let standardPipelines: StandardPipelines
    private let keyStrokeListener: KeyStrokeListening

    private var filtering: Bool = false

    // MARK: - Constructor

    init(
        title: String?,
        question: String,
        description: String?,
        options: T.Type,
        collapseOnSelection: Bool = true,
        theme: NooraTheme,
        terminal: Terminaling = Terminal.current()!,
        renderer: Rendering = Renderer(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener()
    ) {
        self.title = title
        self.question = question
        self.description = description
        self.options = options
        self.theme = theme
        self.terminal = terminal
        self.collapseOnSelection = collapseOnSelection
        self.keyStrokeListener = keyStrokeListener
        self.standardPipelines = standardPipelines
        self.renderer = renderer
    }

    func run() -> T {
        let allOptions = Array(T.allCases)
        var selectedOption: T! = allOptions.first

        terminal.inRawMode { [weak self] in
            guard let self else { return }
            self.renderOptions(selectedOption: selectedOption)
            self.keyStrokeListener.listen(terminal: self.terminal) { [weak self] keyStroke in
                switch keyStroke {
                case .qKey, .returnKey:
                    return .abort
                case .kKey, .upArrowKey:
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex - 1 + allOptions.count) % allOptions.count]
                    self?.renderOptions(selectedOption: selectedOption)
                    return .continue
                case .jKey, .downArrowKey:
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex + 1 + allOptions.count) % allOptions.count]
                    self?.renderOptions(selectedOption: selectedOption)
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
