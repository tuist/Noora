import Foundation
import Rainbow

public enum SingleChoicePromptFilterMode {
    /// Filtering is disabled.
    case disabled
    /// Filtering can be toggled with "/" and "esc".
    case toggleable
    /// Filtering is always enabled.
    case enabled
}

struct SingleChoicePrompt {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let filterMode: SingleChoicePromptFilterMode
    let autoselectSingleChoice: Bool
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
        if autoselectSingleChoice, options.count == 1 {
            renderResult(selectedOption: options[0])
            return options[0].0
        }

        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }
        var selectedOption: (T, String)! = options.first
        var isFiltered = filterMode == .enabled
        var filter = ""

        func getFilteredOptions() -> [(T, String)] {
            if isFiltered, !filter.isEmpty {
                return options.filter { $0.1.localizedCaseInsensitiveContains(filter) }
            }
            return options
        }

        terminal.inRawMode {
            renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case let .printable(character) where character.isNewline:
                    return .abort
                case let .printable(character) where isFiltered:
                    filter.append(character)
                    let filteredOptions = getFilteredOptions()
                    if !filteredOptions.isEmpty {
                        selectedOption = filteredOptions.first!
                    }
                    renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
                    return .continue
                case .backspace where isFiltered, .delete where isFiltered:
                    if !filter.isEmpty {
                        filter.removeLast()
                        let filteredOptions = getFilteredOptions()
                        if !filteredOptions.isEmpty, !filteredOptions.contains(where: { $0 == selectedOption }) {
                            selectedOption = filteredOptions.first!
                        }
                        renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
                    }
                    return .continue
                case let .printable(character) where character == "k":
                    fallthrough
                case .upArrowKey:
                    let filteredOptions = getFilteredOptions()
                    if !filteredOptions.isEmpty {
                        let currentIndex = filteredOptions.firstIndex(where: { $0 == selectedOption })!
                        selectedOption = filteredOptions[(currentIndex - 1 + filteredOptions.count) % filteredOptions.count]
                        renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
                    }
                    return .continue
                case let .printable(character) where character == "j":
                    fallthrough
                case .downArrowKey:
                    let filteredOptions = getFilteredOptions()
                    if !filteredOptions.isEmpty {
                        let currentIndex = filteredOptions.firstIndex(where: { $0 == selectedOption })!
                        selectedOption = filteredOptions[(currentIndex + 1 + filteredOptions.count) % filteredOptions.count]
                        renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
                    }
                    return .continue
                case let .printable(character) where character == "/" && filterMode == .toggleable:
                    isFiltered = true
                    filter = ""
                    renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
                    return .continue
                case .escape where isFiltered:
                    isFiltered = filterMode == .enabled
                    filter = ""
                    renderOptions(selectedOption: selectedOption, options: options, isFiltered: isFiltered, filter: filter)
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
        let currentIndex = options.firstIndex(where: { $0 == selectedOption }) ?? 0
        let middleIndex = rows / 2

        var startIndex = max(0, currentIndex - middleIndex)
        if startIndex + rows > options.count {
            startIndex = max(0, options.count - rows)
        }

        let endIndex = min(options.count, startIndex + rows)

        return startIndex ..< endIndex
    }

    private func renderOptions<T: Equatable>(
        selectedOption: (T, String),
        options: [(T, String)],
        isFiltered: Bool,
        filter: String
    ) {
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
        if isFiltered {
            header +=
                "\n\(titleOffset)\("Filter:".hexIfColoredTerminal(theme.muted, terminal)) \(filter.hexIfColoredTerminal(theme.primary, terminal))"
        }

        // Footer

        let footer = if filterMode == .disabled {
            "\n\(titleOffset)\("↑/↓/k/j up/down • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        } else if isFiltered {
            "\n\(titleOffset)\("↑/↓ up/down • esc clear filter • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        } else {
            "\n\(titleOffset)\("↑/↓/k/j up/down • / filter • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        }

        let headerLines = numberOfLines(for: header)
        let footerLines = numberOfLines(for: footer) + 1 /// `Renderer.render` adds a newline at the end

        let filteredOptions = if isFiltered, !filter.isEmpty {
            options.filter { $0.1.lowercased().contains(filter.lowercased()) }
        } else {
            options
        }

        let maxVisibleOptions = if let terminalSize = terminal.size() {
            max(1, terminalSize.rows - headerLines - footerLines)
        } else {
            filteredOptions.count
        }

        let visibleRange = visibleRange(
            selectedOption: selectedOption,
            options: filteredOptions,
            rows: maxVisibleOptions
        )

        // Questions

        var visibleOptions = [String]()
        for (index, option) in filteredOptions.enumerated() where visibleRange ~= index {
            if option == selectedOption {
                visibleOptions.append("\(titleOffset)  \("❯".hex(theme.primary)) \(option.1)")
            } else {
                visibleOptions.append("\(titleOffset)    \(option.1)")
            }
        }
        let questions = visibleOptions.joined(separator: "\n")

        // Render

        let content = "\(header)\n\(questions)\(footer)"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
