import Foundation
import Logging
import Rainbow

public enum MultipleChoicePromptFilterMode {
    /// Filtering is disabled.
    case disabled
    /// Filtering can be toggled with "/" and "esc".
    case toggleable
    /// Filtering is always enabled.
    case enabled
}


public enum MultipleChoiceLimit {
    /// Unlimited selected options
    case unlimited
    /// Selected options limited to specific value, error message shown to user when limit reached
    case limited(count: Int, errorMessage: String)
}

struct MultipleChoicePrompt {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let filterMode: MultipleChoicePromptFilterMode
    let maxLimit: MultipleChoiceLimit
    let minLimit: MultipleChoiceLimit
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger?

    func run<T: CustomStringConvertible & Equatable>(options: [T]) -> [T] {
        run(options: options.map { ($0, $0.description) })
    }

    func run<T: CaseIterable & CustomStringConvertible & Equatable>() -> [T] {
        run(options: Array(T.allCases).map { ($0, $0.description) })
    }

    // MARK: - Private

    private func run<T: Equatable>(options: [(T, String)]) -> [T] {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }
        if case let (.limited(min, _), .limited(max, _)) = (minLimit, maxLimit) {
            precondition(min <= max, "minLimit cannot be greater than maxLimit")
        }

        var currentOption: (T, String)! = options.first
        var selectedOptions: [(T, String)] = []
        var isFiltered = filterMode == .enabled
        var filter = ""
        var limitError: String?

        func getFilteredOptions() -> [(T, String)] {
            if isFiltered, !filter.isEmpty {
                return options.filter { $0.1.localizedCaseInsensitiveContains(filter) }
            }
            return options
        }

        func render() -> Void {
            renderOptions(
                currentOption: currentOption,
                selectedOptions: selectedOptions,
                options: options,
                isFiltered: isFiltered,
                filter: filter,
                limitError: limitError,
            )
        }

        logger?.debug("Prompting for '\(question.plain())' with options: \(options.map(\.1).joined(separator: ", "))")

        terminal.inRawMode {
            render()

            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                limitError = nil

                switch keyStroke {
                case .returnKey:
                    if case .limited(let count, let errorMessage) = minLimit, selectedOptions.count < count {
                        limitError = errorMessage
                        render()
                        return .continue
                    }

                    return .abort
                case let .printable(character) where character == " ":
                    let filteredOptions = getFilteredOptions()
                    guard !filteredOptions.isEmpty else {
                        return .continue
                    }
                    if let index = selectedOptions.firstIndex(where: { $0 == currentOption }) {
                        selectedOptions.remove(at: index)
                    } else if case .limited(let count, let errorMessage) = maxLimit, selectedOptions.count == count {
                        limitError = errorMessage
                    } else {
                        selectedOptions.append(currentOption)
                    }
                    render()
                    return .continue
                case let .printable(character) where isFiltered && character != "k" && character != "j":
                    filter.append(character)
                    let filteredOptions = getFilteredOptions()
                    if !filteredOptions.isEmpty {
                        currentOption = filteredOptions.first!
                    }
                    render()
                    return .continue
                case .backspace where isFiltered, .delete where isFiltered:
                    guard !filter.isEmpty else {
                        return .continue
                    }
                    filter.removeLast()
                    let filteredOptions = getFilteredOptions()
                    if !filteredOptions.isEmpty, !filteredOptions.contains(where: { $0 == currentOption }) {
                        currentOption = filteredOptions.first!
                    }
                    render()
                    return .continue
                case let .printable(character) where character == "k":
                    fallthrough
                case .upArrowKey:
                    let filteredOptions = getFilteredOptions()
                    guard !filteredOptions.isEmpty else {
                        return .continue
                    }
                    let currentIndex = filteredOptions.firstIndex(where: { $0 == currentOption })!
                    currentOption = filteredOptions[(currentIndex - 1 + filteredOptions.count) % filteredOptions.count]
                    render()
                    return .continue
                case let .printable(character) where character == "j":
                    fallthrough
                case .downArrowKey:
                    let filteredOptions = getFilteredOptions()
                    guard !filteredOptions.isEmpty else {
                        return .continue
                    }

                    let currentIndex = filteredOptions.firstIndex(where: { $0 == currentOption })!
                    currentOption = filteredOptions[(currentIndex + 1 + filteredOptions.count) % filteredOptions.count]
                    render()
                    return .continue
                case let .printable(character) where character == "/" && filterMode == .toggleable:
                    isFiltered = true
                    filter = ""
                    render()
                    return .continue
                case .escape where isFiltered:
                    isFiltered = filterMode == .enabled
                    filter = ""
                    render()
                    return .continue
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(selectedOptions: selectedOptions)
        }

        logger?.debug(
            "Options '\(selectedOptions.map { $0.1 }.joined(separator: " "))' selected for the question '\(question.plain())'"
        )
        return selectedOptions.map { $0.0 }
    }

    private func renderResult(selectedOptions: [(some Equatable, String)]) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(question.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        content += " \(selectedOptions.map { $0.1 }.joined(separator: " "))"
        renderer.render(
            .progressCompletionMessage(content, theme: theme, terminal: terminal),
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
        currentOption: (T, String)?,
        options: [(T, String)],
        rows: Int
    ) -> Range<Int> {
        let defaultIndex = options.isEmpty ? 0 : options.count - 1
        let currentIndex = currentOption.flatMap {
            option in options.firstIndex(where: { $0 == option })
        } ?? defaultIndex
        let middleIndex = rows / 2

        var startIndex = max(0, currentIndex - middleIndex)
        if startIndex + rows > options.count {
            startIndex = max(0, options.count - rows)
        }

        let endIndex = min(options.count, startIndex + rows)

        return startIndex ..< endIndex
    }

    private func renderOptions<T: Equatable>(
        currentOption: (T, String),
        selectedOptions: [(T, String)],
        options: [(T, String)],
        isFiltered: Bool,
        filter: String,
        limitError: String?,
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

        var footer = if filterMode == .disabled {
            "\n\(titleOffset)\("↑/↓/k/j up/down • [space] select • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        } else if isFiltered {
            "\n\(titleOffset)\("↑/↓ up/down • [space] select • esc clear filter • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        } else {
            "\n\(titleOffset)\("↑/↓/k/j up/down • [space] select • / filter • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"
        }

        if let limitError {
            let errorMessage = "Error:\n\(titleOffset)· \(limitError)"

            footer +=
                "\n\(titleOffset)\(TerminalText(stringLiteral: errorMessage).formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.danger, terminal))"
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
            currentOption: currentOption,
            options: filteredOptions,
            rows: maxVisibleOptions
        )

        // Questions

        var visibleOptions = [String]()
        for (index, option) in filteredOptions.enumerated() where visibleRange ~= index {
            let selected = selectedOptions.contains(where: { $0 == option }) ? "◉" : "○"
            if option == currentOption {
                visibleOptions.append("\(titleOffset)\("❯".hex(theme.primary)) \(selected) \(option.1)")
            } else {
                visibleOptions.append("\(titleOffset)  \(selected) \(option.1)")
            }
        }
        let questions = visibleOptions.joined(separator: "\n")

        // Render

        let content = "\(header)\n\(questions)\(footer)"
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
