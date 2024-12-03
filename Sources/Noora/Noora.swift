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
    ///   - theme: The theme to visually configure the prompt.
    ///   - environment: An instance to override the environment state.
    /// - Returns: The option selected by the user.
    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: String? = nil,
        question: String,
        description: String? = nil,
        options: T.Type,
        theme: NooraTheme,
        terminal: Terminal = Terminal.current()!
    ) -> T {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            options: options,
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
    ///   - theme: The theme to visually configure the prompt.
    ///   - environment: An instance to override the environment state.
    /// - Returns: The option selected by the user.
    public func yesOrNoChoicePrompt(
        title: String? = nil,
        question: String,
        defaultAnswer: Bool = true,
        description: String? = nil,
        theme: NooraTheme,
        terminal: Terminal = Terminal.current()!
    ) -> Bool {
        YesOrNoChoicePrompt(
            title: title,
            question: question,
            defaultAnswer: defaultAnswer,
            description: description,
            theme: theme,
            terminal: terminal
        ).run()
    }
}
