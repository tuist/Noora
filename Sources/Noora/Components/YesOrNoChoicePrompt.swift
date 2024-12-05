import Foundation
import Rainbow

struct YesOrNoChoicePrompt {
    // MARK: - Attributes

    private let title: String?
    private let question: String
    private let description: String?
    private let theme: NooraTheme
    private let terminal: Terminaling
    private let collapseOnSelection: Bool
    private let renderer: Rendering
    private let standardPipelines: StandardPipelines
    private let keyStrokeListener: KeyStrokeListening
    private let defaultAnswer: Bool
    private var filtering: Bool = false

    // MARK: - Constructor

    init(
        title: String?,
        question: String,
        defaultAnswer: Bool = true,
        description: String? = nil,
        collapseOnSelection: Bool = true,
        theme: NooraTheme,
        terminal: Terminaling = Terminal.current,
        renderer: Rendering = Renderer(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener()
    ) {
        self.title = title
        self.question = question
        self.defaultAnswer = defaultAnswer
        self.description = description
        self.theme = theme
        self.terminal = terminal
        self.collapseOnSelection = collapseOnSelection
        self.keyStrokeListener = keyStrokeListener
        self.standardPipelines = standardPipelines
        self.renderer = renderer
    }

    func run() -> Bool {
        var answer: Bool = defaultAnswer

        terminal.inRawMode {
            renderOptions(answer: answer)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case .yKey:
                    answer = true
                    return .abort
                case .nKey:
                    answer = false
                    return .abort
                case .leftArrowKey, .rightArrowKey, .lKey, .hKey:
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

        return answer
    }

    // MARK: - Private

    private func renderResult(answer: Bool) {
        var content = if let title {
            "\(title):".hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal)
        } else {
            "\(question):".hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal)
        }
        content += " \(answer ? "Yes" : "No")"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }

    private func renderOptions(answer: Bool) {
        var content = ""
        if let title {
            content = title.hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal)
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

        content += "\n  \(question) \(yes) / \(no)"
        if let description {
            content += "\n  \(description.hexIfColoredTerminal(theme.muted, terminal))"
        }
        content += "\n  \("←/→/h/l left/right • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
