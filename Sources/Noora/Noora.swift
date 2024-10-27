import Foundation

public struct Noora {
    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - question: The quetion to ask to the user.
    ///   - options: The options the user can select from.
    ///   - theme: The theme to visually configure the prompt.
    ///   - environment: An instance to override the environment state.
    /// - Returns: The option selected by the user.
    public func singleChoicePrompt<T>(
        question: String,
        options: [T],
        theme: NooraTheme,
        environment: NooraEnvironment = .default
    ) -> T {
        SingleChoicePrompt(question: question, options: options, theme: theme, environment: environment).run()
    }
}
