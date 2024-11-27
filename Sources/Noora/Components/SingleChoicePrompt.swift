import Foundation
import Rainbow

struct SingleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable> {
    let title: String?
    let question: String
    let description: String?
    let options: T.Type
    let theme: NooraTheme
    let terminal: Terminal
    let collapseOnSelection: Bool
    var renderer: Renderer = .init()
    let standardPipelines = StandardPipelines()
    private var filtering: Bool = false
    private var selectedOption: T!

    init(
        title: String?,
        question: String,
        description: String?,
        options: T.Type,
        collapseOnSelection: Bool = true,
        theme: NooraTheme,
        terminal: Terminal
    ) {
        self.title = title
        self.question = question
        self.description = description
        self.options = options
        self.theme = theme
        self.terminal = terminal
        self.collapseOnSelection = collapseOnSelection
    }

    mutating func run() -> T {
        selectedOption = T.allCases.first

        terminal.inRawMode {
            renderOptions()
            var buffer = ""

            loop: while let char = terminal.readCharacter() {
                let allOptions = Array(T.allCases)
                buffer.append(char)

                // Handle single characters like "q" or "k/j"
                if char == "q" || char == "\n" {
                    break loop
                } else if char == "k" {
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex - 1 + allOptions.count) % allOptions.count]
                    renderOptions()
                    buffer = ""
                    continue
                } else if char == "j" {
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex + 1 + allOptions.count) % allOptions.count]
                    renderOptions()
                    buffer = ""
                    continue
                }

                // Handle escape sequences
                if buffer == "\u{1B}[A" { // Up arrow
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex - 1 + allOptions.count) % allOptions.count]
                    renderOptions()
                    buffer = ""
                } else if buffer == "\u{1B}[B" { // Down arrow
                    let currentIndex = allOptions.firstIndex(where: { $0 == selectedOption })!
                    selectedOption = allOptions[(currentIndex + 1 + allOptions.count) % allOptions.count]
                    renderOptions()
                    buffer = ""
                } else if buffer.count > 3 {
                    buffer = ""
                }
            }
        }

        if collapseOnSelection {
            renderResult(selectedOption)
        }

        return selectedOption
    }

    private mutating func renderResult(_ option: T) {
        var content = if let title {
            "\(title):".hexIfColoredTerminal(theme.primary, terminal: terminal).boldIfColoredTerminal(terminal)
        } else {
            "\(question):".hexIfColoredTerminal(theme.primary, terminal: terminal).boldIfColoredTerminal(terminal)
        }
        content += " \(option.description)\n"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }

    private mutating func renderOptions() {
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
