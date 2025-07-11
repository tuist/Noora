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
}

public class Noora: Noorable {
    let standardPipelines: StandardPipelines
    let theme: Theme
    let terminal: Terminaling
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger?
    let validator: Validator

    public init(
        theme: Theme = .default,
        terminal: Terminaling = Terminal(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener(),
        logger: Logger? = nil
    ) {
        self.theme = theme
        self.terminal = terminal
        self.standardPipelines = standardPipelines
        self.keyStrokeListener = keyStrokeListener
        self.logger = logger
        validator = Validator()
    }

    init(
        theme: Theme = .default,
        terminal: Terminaling = Terminal(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener(),
        logger: Logger? = nil,
        validator: Validator
    ) {
        self.theme = theme
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
            logger: logger
        ).run()
    }

    public func error(_ alert: ErrorAlert) {
        Alert(
            item: .error(alert.message, takeaways: alert.takeaways),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger
        ).run()
    }

    public func info(_ alert: InfoAlert) {
        Alert(
            item: .info(alert.message, takeaways: alert.takeaways),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
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
}

extension Noorable {
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
}
