import Foundation
import Mockable

@Mockable
public protocol Noorable {
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        question: String,
        options: T.Type,
        theme: NooraTheme
    )

    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: String?,
        question: String,
        description: String?,
        options: T.Type,
        collapseOnSelection: Bool,
        theme: NooraTheme,
        terminal: Terminal
    )

    func yesOrNoChoicePrompt(
        title: String?,
        question: String,
        theme: NooraTheme
    )

    func yesOrNoChoicePrompt(
        title: String?,
        question: String,
        defaultAnswer: Bool,
        description: String?,
        collapseOnSelection: Bool,
        theme: NooraTheme,
        terminal: Terminal
    )
}

public struct Noora {
    public init() {}

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - options: The options the user can select from.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    ///   - theme: The theme to visually configure the prompt.
    ///   - terminal: An instance of terminal to override the terminal configuration.
    /// - Returns: The option selected by the user.
    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: String? = nil,
        question: String,
        description: String? = nil,
        options: T.Type,
        collapseOnSelection: Bool = true,
        theme: NooraTheme,
        terminal: Terminal = Terminal.current()!
    ) -> T {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            options: options,
            collapseOnSelection: collapseOnSelection,
            theme: theme,
            terminal: terminal
        )
        _ = component.run()
        return options.allCases.first!
    }

    /// It shows a component to answer yes or no to a question.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - defaultAnswer: Whether the default selected answer is yes or no (true or false)
    ///   - description: An optional description to add additional context around what the question is for.
    ///   - collapseOnSelection: When true, the question is collapsed after the question is entered.
    ///   - theme: The theme to visually configure the prompt.
    ///   - terminal: An instance of terminal to override the terminal configuration.
    /// - Returns: The option selected by the user.
    public func yesOrNoChoicePrompt(
        title: String? = nil,
        question: String,
        defaultAnswer: Bool = true,
        description: String? = nil,
        collapseOnSelection: Bool,
        theme: NooraTheme,
        terminal: Terminal = Terminal.current()!
    ) -> Bool {
        YesOrNoChoicePrompt(
            title: title,
            question: question,
            defaultAnswer: defaultAnswer,
            description: description,
            collapseOnSelection: collapseOnSelection,
            theme: theme,
            terminal: terminal
        ).run()
    }
}
