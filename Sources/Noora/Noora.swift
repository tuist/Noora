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

    /// It shows a completion message.
    /// - Parameter item: The completion item to be shown.
    func completion(_ item: CompletionItem)
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

    public func completion(_ item: CompletionItem) {
        Completion(
            item: item,
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }
}
