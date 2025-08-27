import Foundation
import Logging

public struct WarningAlert: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Equatable, Hashable {
    public let message: TerminalText
    public let takeaway: TerminalText?

    public static func alert(_ message: TerminalText, takeaway: TerminalText? = nil) -> WarningAlert {
        WarningAlert(message, takeaway: takeaway)
    }

    init(_ message: TerminalText, takeaway: TerminalText? = nil) {
        self.message = message
        self.takeaway = takeaway
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        takeaway = nil
    }
}

public struct SuccessAlert: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Equatable, Hashable {
    public let message: TerminalText
    public let takeaways: [TerminalText]

    public static func alert(_ message: TerminalText, takeaways: [TerminalText] = [])
        -> SuccessAlert
    {
        SuccessAlert(message, takeaways: takeaways)
    }

    init(_ message: TerminalText, takeaways: [TerminalText] = []) {
        self.message = message
        self.takeaways = takeaways
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        takeaways = []
    }
}

public struct ErrorAlert: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Equatable, Hashable {
    public let message: TerminalText
    public let takeaways: [TerminalText]

    public static func alert(_ message: TerminalText, takeaways: [TerminalText] = []) -> ErrorAlert {
        ErrorAlert(message, takeaways: takeaways)
    }

    init(_ message: TerminalText, takeaways: [TerminalText] = []) {
        self.message = message
        self.takeaways = takeaways
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        takeaways = []
    }
}

public struct InfoAlert: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Equatable, Hashable {
    public let message: TerminalText
    public let takeaways: [TerminalText]

    public static func alert(_ message: TerminalText, takeaways: [TerminalText] = []) -> InfoAlert {
        InfoAlert(message, takeaways: takeaways)
    }

    init(_ message: TerminalText, takeaways: [TerminalText] = []) {
        self.message = message
        self.takeaways = takeaways
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        takeaways = []
    }
}

public protocol Noorable {
    /// Outputs the given text through the given pipeline.
    /// - Parameters:
    ///   - text: The text to pass through the given pipeline.
    ///   - pipeline: The pipeline to send the text through.
    func passthrough(_ text: TerminalText, pipeline: StandardPipelineType)

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The question to ask to the user.
    ///   - options: The options to show to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    ///   - filterMode: Whether filtering should be disabled, toggleable, or enabled.
    ///   - autoselectSingleChoice: Whether the prompt should automatically select the first item when options only contains one
    /// item.
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: Equatable & CustomStringConvertible>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        renderer: Rendering
    ) -> T

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    ///   - filterMode: Whether filtering should be disabled, toggleable, or enabled.
    ///   - autoselectSingleChoice: Whether the prompt should automatically select the first item when options only contains one
    /// item.
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        renderer: Rendering
    ) -> T

    /// It shows multiple options to the user to select any count of them.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The question to ask to the user.
    ///   - options: The options to show to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    ///   - filterMode: Whether filtering should be disabled, toggleable, or enabled.
    ///   - maxLimit: Use to limit maximum selected options count.
    ///   - minLimit: Use to limit minimum selected options count.
    /// item.
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: The option selected by the user.
    func multipleChoicePrompt<T: Equatable & CustomStringConvertible>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: MultipleChoicePromptFilterMode,
        maxLimit: MultipleChoiceLimit,
        minLimit: MultipleChoiceLimit,
        renderer: Rendering
    ) -> [T]

    /// It shows multiple options to the user to select any count of them.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    ///   - filterMode: Whether filtering should be disabled, toggleable, or enabled.
    ///   - maxLimit: Use to limit maximum selected options count.
    ///   - minLimit: Use to limit minimum selected options count.
    /// item.
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: The option selected by the user.
    func multipleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: MultipleChoicePromptFilterMode,
        maxLimit: MultipleChoiceLimit,
        minLimit: MultipleChoiceLimit,
        renderer: Rendering
    ) -> [T]

    /// It shows a component to answer yes or no to a question.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - defaultAnswer: Whether the default selected answer is yes or no (true or false)
    ///   - description: An optional description to add additional context around what the question is for.
    ///   - collapseOnSelection: When true, the question is collapsed after the question is entered.
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: The option selected by the user.
    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText,
        defaultAnswer: Bool,
        description: TerminalText?,
        collapseOnSelection: Bool,
        renderer: Rendering
    ) -> Bool

    /// It prompts the user for some information.
    /// - Parameters:
    ///   - title: The thing the user is being prompted for.
    ///   - prompt: The prompt message.
    ///   - description: An optional description to clarify what the prompt is for.
    ///   - collapseOnSelection: Whether the prompt should be collasped on answered.
    ///   - renderer: A rendering interface that holds the UI state.
    ///   - validationRules: An array of rules used for input validation.
    /// - Returns: The user's response.
    func textPrompt(
        title: TerminalText?,
        prompt: TerminalText,
        description: TerminalText?,
        collapseOnAnswer: Bool,
        renderer: Rendering,
        validationRules: [ValidatableRule]
    ) -> String

    /// It shows a success alert.
    /// - Parameters:
    ///   - alert: The success message
    func success(_ alert: SuccessAlert)

    /// It shows an error alert.
    /// - Parameters:
    ///   - alert: The error message
    func error(_ alert: ErrorAlert)

    /// It shows a warning alert.
    /// - Parameters:
    ///   - alerts: The warning messages.
    func warning(_ alerts: WarningAlert...)

    /// It shows a warning alert.
    /// - Parameters:
    ///   - alerts: The warning messages.
    func warning(_ alerts: [WarningAlert])

    /// It shows an info alert.
    /// - Parameters:
    ///   - alert: The info message
    func info(_ alert: InfoAlert)

    /// Shows a progress step.
    /// - Parameters:
    ///   - message: The message that represents "what's being done"
    ///   - successMessage: The message that the step gets updated to when the action completes.
    ///   - errorMessage: The message that the step gets updated to when the action errors.
    ///   - showSpinner: True to show a spinner.
    ///   - renderer: A rendering interface that holds the UI state.
    ///   - task: The asynchronous task to run. The caller can use the argument that the function takes to update the step
    /// message.
    func progressStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        renderer: Rendering,
        task: @escaping ((String) -> Void) async throws -> V
    ) async throws -> V

    /// A component to represent long-running operations showing the last lines of the sub-process,
    /// and collapsing it on completion.
    /// - Parameters:
    ///   - title: A representative title of the underlying operation.
    ///   - successMessage: A message that's shown on success.
    ///   - errorMessage: A message that's shown on completion
    ///   - visibleLines: The number of lines to show from the underlying task.
    ///   - renderer: A rendering interface that holds the UI state.
    ///   - task: The task to run.
    func collapsibleStep(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        renderer: Rendering,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws

    /// Formats the given terminal text using the current theme.
    /// - Parameter terminalText: The terminal text to format.
    /// - Returns: The formatted text as a String.
    func format(_ terminalText: TerminalText) -> String

    /// Shows a progress bar step.
    /// - Parameters:
    ///   - message: The message that represents "what's being done"
    ///   - successMessage: The message that the step gets updated to when the action completes.
    ///   - errorMessage: The message that the step gets updated to when the action errors.
    ///   - renderer: A rendering interface that holds the UI state.
    ///   - task: The asynchronous task to run. The caller can use the argument that the function takes to update the progress.
    /// The value should be between 0 and 1.
    /// message.
    func progressBarStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        renderer: Rendering,
        task: @escaping (@escaping (Double) -> Void) async throws -> V
    ) async throws -> V

    /// Displays a static table
    /// - Parameters:
    ///   - headers: Column headers
    ///   - rows: Table data rows
    ///   - renderer: A rendering interface that holds the UI state.
    func table(
        headers: [String],
        rows: [[String]],
        renderer: Rendering
    )

    /// Displays a static table with advanced customization
    /// - Parameters:
    ///   - data: TableData with custom columns, and content
    ///   - renderer: A rendering interface that holds the UI state.
    func table(
        _ data: TableData,
        renderer: Rendering
    )

    /// Displays a static table with semantic styling
    /// - Parameters:
    ///   - headers: Column headers with semantic styling
    ///   - rows: Table data rows with semantic styling
    ///   - renderer: A rendering interface that holds the UI state.
    func table(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        renderer: Rendering
    )

    /// Displays a selectable table for row selection
    /// - Parameters:
    ///   - headers: Column headers
    ///   - rows: Table data rows
    ///   - pageSize: Number of rows visible at once
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: Selected row index
    func selectableTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering
    ) async throws -> Int

    /// Displays a selectable table for row selection with advanced customization
    /// - Parameters:
    ///   - data: TableData with custom columns, styling, and content
    ///   - pageSize: Number of rows visible at once
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: Selected row index
    func selectableTable(
        _ data: TableData,
        pageSize: Int,
        renderer: Rendering
    ) async throws -> Int

    /// Displays a selectable table for row selection with semantic styling
    /// - Parameters:
    ///   - headers: Column headers with semantic styling
    ///   - rows: Table data rows with semantic styling
    ///   - pageSize: Number of rows visible at once
    ///   - renderer: A rendering interface that holds the UI state.
    /// - Returns: Selected row index
    func selectableTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering
    ) async throws -> Int

    /// Displays a paginated table for large datasets
    /// - Parameters:
    ///   - headers: Column headers
    ///   - rows: Table data rows
    ///   - pageSize: Number of rows per page
    ///   - renderer: A rendering interface that holds the UI state.
    func paginatedTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering
    ) throws

    /// Displays a paginated table for large datasets with advanced customization
    /// - Parameters:
    ///   - data: TableData with custom columns, styling, and content
    ///   - pageSize: Number of rows per page
    ///   - renderer: A rendering interface that holds the UI state.
    func paginatedTable(
        _ data: TableData,
        pageSize: Int,
        renderer: Rendering
    ) throws

    /// Displays a paginated table for large datasets with semantic styling
    /// - Parameters:
    ///   - headers: Column headers with semantic styling
    ///   - rows: Table data rows with semantic styling
    ///   - pageSize: Number of rows per page
    ///   - renderer: A rendering interface that holds the UI state.
    func paginatedTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering
    ) throws

    /// Pretty prints a Codable object as JSON.
    /// - Parameter item: The Codable object to pretty print as JSON.
    /// - Parameter encoder: The encoder to use for encoding the item.
    /// - Throws: An error if the object cannot be encoded to JSON.
    func json(_ item: some Codable, encoder: JSONEncoder) throws
}

// swiftlint:disable:next type_body_length
public class Noora: Noorable {
    let standardPipelines: StandardPipelines
    let theme: Theme
    let content: Content
    let terminal: Terminaling
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger?
    let validator: Validator

    public init(
        theme: Theme = .default,
        content: Content = .default,
        terminal: Terminaling = Terminal(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener(),
        logger: Logger? = nil
    ) {
        self.theme = theme
        self.content = content
        self.terminal = terminal
        self.standardPipelines = standardPipelines
        self.keyStrokeListener = keyStrokeListener
        self.logger = logger
        validator = Validator()
    }

    init(
        theme: Theme = .default,
        content: Content = .default,
        terminal: Terminaling = Terminal(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener(),
        logger: Logger? = nil,
        validator: Validator
    ) {
        self.theme = theme
        self.content = content
        self.terminal = terminal
        self.standardPipelines = standardPipelines
        self.keyStrokeListener = keyStrokeListener
        self.logger = logger
        self.validator = validator
    }

    public func singleChoicePrompt<T>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        renderer: Rendering
    ) -> T where T: CustomStringConvertible, T: Equatable {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            content: content,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            renderer: renderer,
            standardPipelines: standardPipelines,
            keyStrokeListener: keyStrokeListener,
            logger: logger
        )
        return component.run(options: options)
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        renderer: Rendering
    ) -> T {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            content: content,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            renderer: renderer,
            standardPipelines: standardPipelines,
            keyStrokeListener: keyStrokeListener,
            logger: logger
        )
        return component.run()
    }

    public func multipleChoicePrompt<T>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: MultipleChoicePromptFilterMode,
        maxLimit: MultipleChoiceLimit,
        minLimit: MultipleChoiceLimit,
        renderer: Rendering
    ) -> [T] where T: CustomStringConvertible, T: Equatable {
        let component = MultipleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            maxLimit: maxLimit,
            minLimit: minLimit,
            renderer: renderer,
            standardPipelines: standardPipelines,
            keyStrokeListener: keyStrokeListener,
            logger: logger
        )
        return component.run(options: options)
    }

    public func multipleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: MultipleChoicePromptFilterMode,
        maxLimit: MultipleChoiceLimit,
        minLimit: MultipleChoiceLimit,
        renderer: Rendering
    ) -> [T] {
        let component = MultipleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            maxLimit: maxLimit,
            minLimit: minLimit,
            renderer: renderer,
            standardPipelines: standardPipelines,
            keyStrokeListener: keyStrokeListener,
            logger: logger
        )
        return component.run()
    }

    public func textPrompt(
        title: TerminalText?,
        prompt: TerminalText,
        description: TerminalText?,
        collapseOnAnswer: Bool,
        renderer: Rendering,
        validationRules: [ValidatableRule]
    ) -> String {
        let component = TextPrompt(
            title: title,
            prompt: prompt,
            description: description,
            theme: theme,
            content: content,
            terminal: terminal,
            collapseOnAnswer: collapseOnAnswer,
            renderer: renderer,
            standardPipelines: standardPipelines,
            logger: logger,
            validationRules: validationRules,
            validator: validator
        )
        return component.run()
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool,
        renderer: Rendering
    ) -> Bool {
        YesOrNoChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            content: content,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: renderer,
            standardPipelines: standardPipelines,
            keyStrokeListener: keyStrokeListener,
            defaultAnswer: defaultAnswer,
            logger: logger
        ).run()
    }

    public func success(_ alert: SuccessAlert) {
        Alert(
            item: .success(alert.message, takeaways: alert.takeaways),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            content: content,
            logger: logger
        ).run()
    }

    public func error(_ alert: ErrorAlert) {
        Alert(
            item: .error(alert.message, takeaways: alert.takeaways),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            content: content,
            logger: logger
        ).run()
    }

    public func info(_ alert: InfoAlert) {
        Alert(
            item: .info(alert.message, takeaways: alert.takeaways),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            content: content,
            logger: logger
        ).run()
    }

    public func warning(_ alerts: WarningAlert...) {
        warning(alerts)
    }

    public func warning(_ alerts: [WarningAlert]) {
        Alert(
            item: .warning(alerts.map { (message: $0.message, takeaway: $0.takeaway) }),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            content: content,
            logger: logger
        ).run()
    }

    public func progressStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        renderer: Rendering,
        task: @escaping ((String) -> Void) async throws -> V
    ) async throws -> V {
        let progressStep = ProgressStep(
            message: message,
            successMessage: successMessage,
            errorMessage: errorMessage,
            showSpinner: showSpinner,
            task: task,
            theme: theme,
            terminal: terminal,
            renderer: renderer,
            standardPipelines: standardPipelines,
            logger: logger
        )
        return try await progressStep.run()
    }

    public func collapsibleStep(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        renderer: Rendering,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await CollapsibleStep(
            title: title,
            successMessage: successMessage,
            errorMessage: errorMessage,
            visibleLines: visibleLines,
            task: task,
            theme: theme,
            terminal: terminal,
            renderer: renderer,
            standardPipelines: standardPipelines,
            logger: logger
        ).run()
    }

    public func format(_ terminalText: TerminalText) -> String {
        terminalText.formatted(theme: theme, terminal: terminal)
    }

    public func progressBarStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        renderer: Rendering,
        task: @escaping (@escaping (Double) -> Void) async throws -> V
    ) async throws -> V {
        try await ProgressBarStep(
            message: message,
            successMessage: successMessage,
            errorMessage: errorMessage,
            task: task,
            theme: theme,
            terminal: terminal,
            renderer: renderer,
            standardPipelines: standardPipelines,
            logger: logger
        )
        .run()
    }

    public func table(
        headers: [String],
        rows: [[String]],
        renderer: Rendering
    ) {
        let tableData = createTableData(headers: headers, rows: rows)
        table(tableData, renderer: renderer)
    }

    public func table(
        _ data: TableData,
        renderer _: Rendering
    ) {
        Table(
            data: data,
            style: theme.tableStyle,
            renderer: Renderer(),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger,
            tableRenderer: TableRenderer()
        )
        .run()
    }

    public func table(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        renderer: Rendering
    ) {
        let tableData = createStyledTableData(headers: headers, rows: rows)
        table(tableData, renderer: renderer)
    }

    public func selectableTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering
    ) async throws -> Int {
        let tableData = createTableData(headers: headers, rows: rows)
        return try await selectableTable(
            tableData,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func selectableTable(
        _ data: TableData,
        pageSize: Int,
        renderer _: Rendering
    ) async throws -> Int {
        guard terminal.isInteractive else {
            throw NooraError.nonInteractiveTerminal
        }

        return try SelectableTable(
            data: data,
            style: theme.tableStyle,
            pageSize: pageSize,
            renderer: Renderer(),
            terminal: terminal,
            standardPipelines: standardPipelines,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger,
            tableRenderer: TableRenderer()
        ).run()
    }

    public func selectableTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering
    ) async throws -> Int {
        let tableData = createStyledTableData(headers: headers, rows: rows)
        return try await selectableTable(
            tableData,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func paginatedTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering
    ) throws {
        let tableData = createTableData(headers: headers, rows: rows)
        return try paginatedTable(
            tableData,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func paginatedTable(
        _ data: TableData,
        pageSize: Int,
        renderer _: Rendering
    ) throws {
        try PaginatedTable(
            data: data,
            style: theme.tableStyle,
            pageSize: pageSize,
            renderer: Renderer(),
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer()
        ).run()
    }

    public func paginatedTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering
    ) throws {
        let tableData = createStyledTableData(headers: headers, rows: rows)
        return try paginatedTable(
            tableData,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func passthrough(_ text: TerminalText, pipeline: StandardPipelineType) {
        switch pipeline {
        case .error:
            standardPipelines.error.write(content: text.formatted(theme: theme, terminal: terminal))
        case .output:
            standardPipelines.output.write(content: text.formatted(theme: theme, terminal: terminal))
        }
    }

    public func json(_ item: some Codable, encoder: JSONEncoder) throws {
        let jsonData = try encoder.encode(item)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            let text = TerminalText(stringLiteral: jsonString)
            passthrough(text, pipeline: .output)
        }
    }

    /// Helper method to convert simple string arrays to TableData
    private func createTableData(headers: [String], rows: [[String]]) -> TableData {
        // Create columns with automatic width and left alignment by default
        let columns = headers.map { header in
            TableColumn(
                title: TerminalText(
                    stringLiteral: header
                ),
                width: .auto,
                alignment: .left
            )
        }

        // Convert string rows to TerminalText rows
        let terminalRows: [[TerminalText]] = rows.map { row in
            row.map { cell in
                TerminalText(stringLiteral: cell)
            }
        }

        return TableData(columns: columns, rows: terminalRows)
    }

    /// Helper method to convert styled arrays to TableData
    private func createStyledTableData(headers: [TableCellStyle], rows: [StyledTableRow])
        -> TableData
    {
        // Create columns with automatic width and left alignment by default
        let columns = headers.map { header in
            TableColumn(title: header.toTerminalText(), width: .auto, alignment: .left)
        }

        return TableData(columns: columns, styledRows: rows)
    }
}

extension Noorable {
    /// Writes a terminal text into the standard ouptut pipeline.
    /// - Parameter text: The text to write.
    public func passthrough(_ text: TerminalText) {
        passthrough(text, pipeline: .output)
    }

    public func singleChoicePrompt<T>(
        title: TerminalText? = nil,
        question: TerminalText,
        options: [T],
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: SingleChoicePromptFilterMode = .disabled,
        autoselectSingleChoice: Bool = true,
        renderer: Rendering = Renderer()
    ) -> T where T: CustomStringConvertible, T: Equatable {
        singleChoicePrompt(
            title: title,
            question: question,
            options: options,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            renderer: renderer
        )
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: SingleChoicePromptFilterMode = .disabled,
        autoselectSingleChoice: Bool = true,
        renderer: Rendering = Renderer()
    ) -> T {
        singleChoicePrompt(
            title: title,
            question: question,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            renderer: renderer
        )
    }

    public func multipleChoicePrompt<T>(
        title: TerminalText? = nil,
        question: TerminalText,
        options: [T],
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: MultipleChoicePromptFilterMode = .disabled,
        maxLimit: MultipleChoiceLimit = .unlimited,
        minLimit: MultipleChoiceLimit = .unlimited,
        renderer: Rendering = Renderer()
    ) -> [T] where T: CustomStringConvertible, T: Equatable {
        multipleChoicePrompt(
            title: title,
            question: question,
            options: options,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            maxLimit: maxLimit,
            minLimit: minLimit,
            renderer: renderer
        )
    }

    public func multipleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: MultipleChoicePromptFilterMode = .disabled,
        maxLimit: MultipleChoiceLimit = .unlimited,
        minLimit: MultipleChoiceLimit = .unlimited,
        renderer: Rendering = Renderer()
    ) -> [T] {
        multipleChoicePrompt(
            title: title,
            question: question,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            maxLimit: maxLimit,
            minLimit: minLimit,
            renderer: renderer
        )
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        renderer: Rendering = Renderer()
    ) -> Bool {
        yesOrNoChoicePrompt(
            title: title,
            question: question,
            defaultAnswer: defaultAnswer,
            description: description,
            collapseOnSelection: collapseOnSelection,
            renderer: renderer
        )
    }

    public func textPrompt(
        title: TerminalText? = nil,
        prompt: TerminalText,
        description: TerminalText? = nil,
        collapseOnAnswer: Bool = true,
        renderer: Rendering = Renderer(),
        validationRules: [ValidatableRule] = []
    ) -> String {
        textPrompt(
            title: title,
            prompt: prompt,
            description: description,
            collapseOnAnswer: collapseOnAnswer,
            renderer: renderer,
            validationRules: validationRules
        )
    }

    public func progressStep<V>(
        message: String,
        task: @escaping ((String) -> Void) async throws -> V
    ) async throws -> V {
        try await progressStep(
            message: message,
            successMessage: nil,
            errorMessage: nil,
            showSpinner: true,
            renderer: Renderer(),
            task: task
        )
    }

    public func progressStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        task: @escaping ((String) -> Void) async throws -> V
    ) async throws -> V {
        try await progressStep(
            message: message,
            successMessage: successMessage,
            errorMessage: errorMessage,
            showSpinner: showSpinner,
            renderer: Renderer(),
            task: task
        )
    }

    public func collapsibleStep(
        title: TerminalText,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await collapsibleStep(
            title: title,
            successMessage: nil,
            errorMessage: nil,
            visibleLines: 3,
            renderer: Renderer(),
            task: task
        )
    }

    public func collapsibleStep(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await collapsibleStep(
            title: title,
            successMessage: successMessage,
            errorMessage: errorMessage,
            visibleLines: visibleLines,
            renderer: Renderer(),
            task: task
        )
    }

    public func progressBarStep<V>(
        message: String,
        task: @escaping (@escaping (Double) -> Void) async throws -> V
    ) async throws -> V {
        try await progressBarStep(
            message: message,
            successMessage: nil,
            errorMessage: nil,
            renderer: Renderer(),
            task: task
        )
    }

    public func progressBarStep<V>(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        task: @escaping (@escaping (Double) -> Void) async throws -> V
    ) async throws -> V {
        try await progressBarStep(
            message: message,
            successMessage: successMessage,
            errorMessage: errorMessage,
            renderer: Renderer(),
            task: task
        )
    }

    public func table(
        headers: [String],
        rows: [[String]],
        renderer: Rendering = Renderer()
    ) {
        table(
            headers: headers,
            rows: rows,
            renderer: renderer
        )
    }

    public func table(
        _ data: TableData,
        renderer: Rendering = Renderer()
    ) {
        table(data, renderer: renderer)
    }

    public func table(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        renderer: Rendering = Renderer()
    ) {
        table(
            headers: headers,
            rows: rows,
            renderer: renderer
        )
    }

    public func selectableTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) async throws -> Int {
        try await selectableTable(
            headers: headers,
            rows: rows,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func selectableTable(
        _ data: TableData,
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) async throws -> Int {
        try await selectableTable(
            data,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func selectableTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) async throws -> Int {
        try await selectableTable(
            headers: headers,
            rows: rows,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func paginatedTable(
        headers: [String],
        rows: [[String]],
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) throws {
        try paginatedTable(
            headers: headers,
            rows: rows,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func paginatedTable(
        _ data: TableData,
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) throws {
        try paginatedTable(
            data,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    public func paginatedTable(
        headers: [TableCellStyle],
        rows: [StyledTableRow],
        pageSize: Int,
        renderer: Rendering = Renderer()
    ) throws {
        try paginatedTable(
            headers: headers,
            rows: rows,
            pageSize: pageSize,
            renderer: renderer
        )
    }

    /// Pretty prints a Codable object as JSON.
    /// - Parameter item: The Codable object to pretty print as JSON.
    /// - Throws: An error if the object cannot be encoded to JSON.
    public func json(_ item: some Codable) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try json(item, encoder: encoder)
    }
}
