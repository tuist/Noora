import Foundation
import Mockable

@Mockable
public protocol Noorable {
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        question: String
    ) -> T

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: String?,
        question: String,
        description: String?,
        collapseOnSelection: Bool
    ) -> T

    func yesOrNoChoicePrompt(
        title: String?,
        question: String
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
        title: String?,
        question: String,
        defaultAnswer: Bool,
        description: String?,
        collapseOnSelection: Bool
    ) -> Bool
}

public struct Noora: Noorable {
    let theme: Theme
    let terminal: Terminaling

    public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
        self.theme = theme
        self.terminal = terminal
    }

    public func singleChoicePrompt<T>(question: String) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
        singleChoicePrompt(title: nil, question: question, description: nil, collapseOnSelection: true)
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: String? = nil,
        question: String,
        description: String? = nil,
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

    public func yesOrNoChoicePrompt(title: String?, question: String) -> Bool {
        yesOrNoChoicePrompt(title: title, question: question, defaultAnswer: true, description: nil, collapseOnSelection: true)
    }

    public func yesOrNoChoicePrompt(
        title: String? = nil,
        question: String,
        defaultAnswer: Bool = true,
        description: String? = nil,
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
}
