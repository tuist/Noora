import Foundation

public protocol Noorable {
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        question: TerminalText
    ) -> T

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> T

    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText
    ) -> Bool

    /// It shows a component to answer yes or no to a question.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - defaultAnswer: Whether the default selected answer is yes or no (true or false)
    ///   - description: An optional description to add additional context around what the question is for.
    ///   - collapseOnSelection: When true, the question is collapsed after the question is entered.
    /// - Returns: The option selected by the user.
    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText,
        defaultAnswer: Bool,
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> Bool

    /// It shows a success alert.
    /// - Parameters:
    ///   - message: The success message
    ///   - next: A list of steps that the person could take after.
    func success(_ message: TerminalText)

    /// It shows a success alert.
    /// - Parameters:
    ///   - message: The success message
    ///   - next: A list of steps that the person could take after.
    func success(_ message: TerminalText, next: [TerminalText])

    /// It shows an error alert.
    /// - Parameters:
    ///   - message: The error message
    ///   - next: A list of steps that the person could take after.
    func error(_ message: TerminalText)

    /// It shows an error alert.
    /// - Parameters:
    ///   - message: The error message
    ///   - next: A list of steps that the person could take after.
    func error(_ message: TerminalText, next: [TerminalText])

    /// It shows a warning alert.
    /// - Parameters:
    ///   - messages: The warning messages.
    func warning(_ messages: [TerminalText])

    /// It shows a warning alert.
    /// - Parameters:
    ///   - messages: The warning messages.
    func warning(_ messages: [(TerminalText, next: TerminalText?)])
}

public struct Noora: Noorable {
    let theme: Theme
    let terminal: Terminaling

    public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
        self.theme = theme
        self.terminal = terminal
    }

    public func singleChoicePrompt<T>(question: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
        T: Equatable
    {
        singleChoicePrompt(title: nil, question: question, description: nil, collapseOnSelection: true)
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true
    ) -> T {
        let component = SingleChoicePrompt<T>(
            title: title,
            question: question,
            description: description,
            options: T.self,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: Renderer(),
            standardPipelines: StandardPipelines(),
            keyStrokeListener: KeyStrokeListener()
        )
        return component.run()
    }

    public func yesOrNoChoicePrompt(title: TerminalText?, question: TerminalText) -> Bool {
        yesOrNoChoicePrompt(title: title, question: question, defaultAnswer: true, description: nil, collapseOnSelection: true)
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool
    ) -> Bool {
        YesOrNoChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: Renderer(),
            standardPipelines: StandardPipelines(),
            keyStrokeListener: KeyStrokeListener(),
            defaultAnswer: defaultAnswer
        ).run()
    }

    public func success(_ message: TerminalText) {
        success(message, next: [])
    }

    public func success(_ message: TerminalText, next: [TerminalText]) {
        Alert(
            item: .success(message, next: next),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func error(_ message: TerminalText) {
        error(message, next: [])
    }

    public func error(_ message: TerminalText, next: [TerminalText] = []) {
        Alert(
            item: .error(message, next: next),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func warning(_ messages: [TerminalText]) {
        Alert(
            item: .warning(messages.map { (message: $0, next: nil) }),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func warning(_ messages: [(TerminalText, next: TerminalText?)]) {
        Alert(
            item: .warning(messages),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }
}
