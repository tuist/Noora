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

    private func numberOfLines(for text: String) -> Int {
        guard let terminalWidth = terminal.size()?.columns else { return 1 }
        let lines = text.raw.split(separator: "\n")
        return lines.reduce(0) { sum, line in
            let lineCount = (line.count + terminalWidth - 1) / terminalWidth
            return sum + lineCount
        }
    }

    private func visibleRange<T: Equatable>(
        selectedOption: (T, String),
        options: [(T, String)],
        rows: Int
    ) -> Range<Int> {
        let currentIndex = options.firstIndex(where: { $0 == selectedOption })!
        let middleIndex = rows / 2

        var startIndex = max(0, currentIndex - middleIndex)
        if startIndex + rows > options.count {
            startIndex = max(0, options.count - rows)
        }

        let endIndex = min(options.count, startIndex + rows)

        return startIndex ..< endIndex
    }

    private func renderOptions<T: Equatable>(selectedOption: (T, String), options: [(T, String)]) {
        let titleOffset = title != nil ? "  " : ""

        // Header

        var header = ""
        if let title {
            header = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        header += "\(title != nil ? "\n" : "")\(titleOffset)\(question.formatted(theme: theme, terminal: terminal))"
        if let description {
            header +=
                "\n\(titleOffset)\(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }

        // Footer

        let footer = "\n\(titleOffset)\("↑/↓/k/j up/down • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"

        let headerLines = numberOfLines(for: header)
        let footerLines = numberOfLines(for: footer) + 1 /// `Renderer.render` adds a newline at the end

        let maxVisibleOptions = if let terminalSize = terminal.size() {
            max(1, terminalSize.rows - headerLines - footerLines)
        } else {
            options.count
        }

        let visibleRange = visibleRange(
            selectedOption: selectedOption,
            options: options,
            rows: maxVisibleOptions
        )

        // Questions

        var visibleOptions = [String]()
        for (index, option) in options.enumerated() {
            if visibleRange ~= index {
                if option == selectedOption {
                    visibleOptions.append("\(titleOffset)  \("❯".hex(theme.primary)) \(option.1)")
                } else {
                    visibleOptions.append("\(titleOffset)    \(option.1)")
                }
            }
        }
        let questions = visibleOptions.joined(separator: "\n")

        // Render

        let content = "\(header)\n\(questions)\(footer)"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
