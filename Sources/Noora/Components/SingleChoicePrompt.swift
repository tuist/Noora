import Foundation
import Rainbow

struct SingleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable> {
    let title: String?
    let question: String
    let description: String?
    let options: T.Type
    let theme: NooraTheme
    let terminal: Terminal
    var renderer: Renderer = .init()
    let standardPipelines = StandardPipelines()
    private var filtering: Bool = false
    private var selectedOption: T!

    init(title: String?, question: String, description: String?, options: T.Type, theme: NooraTheme, terminal: Terminal) {
        self.title = title
        self.question = question
        self.description = description
        self.options = options
        self.theme = theme
        self.terminal = terminal
    }

    mutating func run() -> T {
        selectedOption = T.allCases.first

        terminal.inRawMode {
            render()

            loop: while let input = terminal.readCharacter() {
                let allOptions = Array(T.allCases)
                switch input {
                case "\u{1B}[A", "k":
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex - 1 + allOptions.count) % allOptions.count]
                    render()
                case "\u{1B}[B", "j":
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex + 1 + allOptions.count) % allOptions.count]
                    render()
                case "\r", "\n", " ":
                    break loop
                case "q":
                    break loop
                default:
                    continue
                }
            }
        }

        return selectedOption
    }

    private mutating func render() {
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
