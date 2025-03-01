import Foundation
import Logging

public struct WarningAlert: ExpressibleByStringLiteral, Equatable {
    let message: TerminalText
    let nextStep: TerminalText?

    public static func alert(_ message: TerminalText, nextStep: TerminalText? = nil) -> WarningAlert {
        WarningAlert(message, nextStep: nextStep)
    }

    init(_ message: TerminalText, nextStep: TerminalText? = nil) {
        self.message = message
        self.nextStep = nextStep
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextStep = nil
    }
}

public struct SuccessAlert: ExpressibleByStringLiteral, Equatable {
    let message: TerminalText
    let nextSteps: [TerminalText]

    public static func alert(_ message: TerminalText, nextSteps: [TerminalText] = [])
        -> SuccessAlert
    {
        SuccessAlert(message, nextSteps: nextSteps)
    }

    init(_ message: TerminalText, nextSteps: [TerminalText] = []) {
        self.message = message
        self.nextSteps = nextSteps
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextSteps = []
    }
}

public struct ErrorAlert: ExpressibleByStringLiteral, Equatable {
    let message: TerminalText
    let nextSteps: [TerminalText]

    public static func alert(_ message: TerminalText, nextSteps: [TerminalText] = []) -> ErrorAlert {
        ErrorAlert(message, nextSteps: nextSteps)
    }

    init(_ message: TerminalText, nextSteps: [TerminalText] = []) {
        self.message = message
        self.nextSteps = nextSteps
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextSteps = []
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
    ///   - logger: Use it to get debug logs.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        logger: Logger?
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
    ///   - logger: Use it to get debug logs.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        logger: Logger?
    ) -> T

    /// It shows a component to answer yes or no to a question.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - defaultAnswer: Whether the default selected answer is yes or no (true or false)
    ///   - description: An optional description to add additional context around what the question is for.
    ///   - collapseOnSelection: When true, the question is collapsed after the question is entered.
    ///   - logger: Use it to get debug logs.
    /// - Returns: The option selected by the user.
    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText,
        defaultAnswer: Bool,
        description: TerminalText?,
        collapseOnSelection: Bool,
        logger: Logger?
    ) -> Bool

    /// It prompts the user for some information.
    /// - Parameters:
    ///   - title: The thing the user is being prompted for.
    ///   - prompt: The prompt message.
    ///   - description: An optional description to clarify what the prompt is for.
    ///   - collapseOnSelection: Whether the prompt should be collasped on answered.
    ///   - logger: Use it to get debug logs.
    /// - Returns: The user's response.
    func textPrompt(
        title: TerminalText?,
        prompt: TerminalText,
        description: TerminalText?,
        collapseOnAnswer: Bool,
        logger: Logger?
    ) -> String

    /// It shows a success alert.
    /// - Parameters:
    ///   - alert: The success message.
    ///   - logger: Use it to get debug logs.
    func success(_ alert: SuccessAlert, logger: Logger?)

    /// It shows an error alert.
    /// - Parameters:
    ///   - alert: The error message.
    ///   - logger: Use it to get debug logs.
    func error(_ alert: ErrorAlert, logger: Logger?)

    /// It shows a warning alert.
    /// - Parameters:
    ///   - alerts: The warning messages.
    ///   - logger: Use it to get debug logs.
    func warning(_ alerts: WarningAlert..., logger: Logger?)

    /// It shows a warning alert.
    /// - Parameters:
    ///   - alerts: The warning messages.
    ///   - logger: Use it to get debug logs.
    func warning(_ alerts: [WarningAlert], logger: Logger?)

    /// Shows a progress step.
    /// - Parameters:
    ///   - message: The message that represents "what's being done"
    ///   - successMessage: The message that the step gets updated to when the action completes.
    ///   - errorMessage: The message that the step gets updated to when the action errors.
    ///   - showSpinner: True to show a spinner.
    ///   - logger: Use it to get debug logs.
    ///   - task: The asynchronous task to run. The caller can use the argument that the function takes to update the step
    /// message.
    func progressStep(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        logger: Logger?
        task: @escaping ((String) -> Void) async throws -> Void
    ) async throws

    /// A component to represent long-running operations showing the last lines of the sub-process,
    /// and collapsing it on completion.
    /// - Parameters:
    ///   - title: A representative title of the underlying operation.
    ///   - successMessage: A message that's shown on success.
    ///   - errorMessage: A message that's shown on completion
    ///   - visibleLines: The number of lines to show from the underlying task.
    ///   - logger: Use it to get debug logs.
    ///   - task: The task to run.
    func collapsibleStep(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        logger: Logger?,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws

    /// Formats the given terminal text using the current theme.
    /// - Parameters:
    ///   - terminalText: The terminal text to format.
    ///   - logger: Use it to get debug logs.
    /// - Returns: The formatted text as a String.
    func format(_ terminalText: TerminalText, logger: Logger?) -> String
}

public class Noora: Noorable {
    let standardPipelines: StandardPipelines
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let keyStrokeListener: KeyStrokeListening

    public init(
        theme: Theme = .default,
        terminal: Terminaling = Terminal(),
        standardPipelines: StandardPipelines = StandardPipelines(),
        renderer: Rendering = Renderer(),
        keyStrokeListener: KeyStrokeListening = KeyStrokeListener()
    ) {
        self.theme = theme
        self.terminal = terminal
        self.standardPipelines = standardPipelines
        self.renderer = renderer
        self.keyStrokeListener = keyStrokeListener
    }

    public func singleChoicePrompt<T>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool,
        filterMode: SingleChoicePromptFilterMode,
        autoselectSingleChoice: Bool,
        logger: Logger?
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
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: SingleChoicePromptFilterMode = .disabled,
        autoselectSingleChoice: Bool = true,
        logger: Logger? = nil
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
        logger?.trace("Prompted the user to select a single choice option for the question '\(question.formatted(theme: self.theme, terminal: self.terminal))'")
        return component.run()
    }

    public func textPrompt(
        title: TerminalText?,
        prompt: TerminalText,
        description: TerminalText?,
        collapseOnAnswer: Bool,
        logger: Logger?
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
            logger: logger
        )
        return component.run()
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool,
        logger: Logger? = nil
    ) -> Bool {
        logger?.trace("Prompted the user to select a YesOrNo choice for the question '\(question.formatted(theme: self.theme, terminal: self.terminal))'")
        
        return YesOrNoChoicePrompt(
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

    public func success(_ alert: SuccessAlert, logger: Logger? = nil) {
        logger?.info("Prompted a success alert with message '\(alert.message.formatted(theme: theme, terminal: terminal))' with nextSteps")
        return Alert(
            item: .success(alert.message, nextSteps: alert.nextSteps),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger
        ).run()
    }

    public func error(_ alert: ErrorAlert, logger: Logger?) {
        logger?.error("Prompted an error alert with message '\(alert.message.formatted(theme: self.theme, terminal: self.terminal))' with nextSteps")
        return Alert(
            item: .error(alert.message, nextSteps: alert.nextSteps),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger
        ).run()
    }

    public func warning(_ alerts: WarningAlert..., logger: Logger?) {
            if let logger {
              _ = alerts.map {
                logger.info("Prompted a warning alert with message '\($0.message.formatted(theme: self.theme, terminal: self.terminal))' with nextSteps")
            }
        }
        warning(alerts, logger: logger)
    }

    public func warning(_ alerts: [WarningAlert], logger: Logger?) {
        Alert(
            item: .warning(alerts.map { (message: $0.message, nextStep: $0.nextStep) }),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger
        ).run()
    }

    public func progressStep(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        logger: Logger?,
        task: @escaping ((String) -> Void) async throws -> Void
    ) async throws {
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
        try await progressStep.run()
    }

    public func collapsibleStep(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        logger: Logger?,
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
}

extension Noorable {
    public func singleChoicePrompt<T: Equatable & CustomStringConvertible>(
        title: TerminalText? = nil,
        question: TerminalText,
        options: [T],
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: SingleChoicePromptFilterMode = .disabled,
        autoselectSingleChoice: Bool = true,
        logger: Logger? = nil
    ) -> T {
        singleChoicePrompt(
            title: title,
            question: question,
            options: options,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            logger: logger
        )
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        filterMode: SingleChoicePromptFilterMode = .disabled,
        autoselectSingleChoice: Bool = true,
        logger: Logger? = nil
    ) -> T {
        singleChoicePrompt(
            title: title,
            question: question,
            description: description,
            collapseOnSelection: collapseOnSelection,
            filterMode: filterMode,
            autoselectSingleChoice: autoselectSingleChoice,
            logger: logger
        )
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true,
        logger: Logger? = nil
    ) -> Bool {
        yesOrNoChoicePrompt(
            title: title,
            question: question,
            defaultAnswer: defaultAnswer,
            description: description,
            collapseOnSelection: collapseOnSelection,
            logger: logger
        )
    }

    public func textPrompt(
        title: TerminalText? = nil,
        prompt: TerminalText,
        description: TerminalText? = nil,
        collapseOnAnswer: Bool = true,
        logger: Logger? = nil
    ) -> String {
        textPrompt(
            title: title, prompt: prompt, description: description,
            collapseOnAnswer: collapseOnAnswer,
            logger: logger
        )
    }

    public func progressStep(
        message: String,
        logger: Logger? = nil,
        task: @escaping ((String) -> Void) async throws -> Void
    ) async throws {
        try await progressStep(
            message: message,
            successMessage: nil,
            errorMessage: nil,
            showSpinner: true,
            logger: logger,
            task: task
        )
    }

    public func collapsibleStep(
        title: TerminalText,
        logger: Logger? = nil,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
    ) async throws {
        try await collapsibleStep(
            title: title,
            successMessage: nil,
            errorMessage: nil,
            visibleLines: 3,
            logger: logger,
            task: task
        )
    }
}
