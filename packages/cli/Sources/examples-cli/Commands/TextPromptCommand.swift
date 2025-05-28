import ArgumentParser
import Foundation
import Noora

struct TextPromptCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "text-prompt",
        abstract: "A component to prompt the user for a text input."
    )

    func run() async throws {
        let input = Noora().textPrompt(
            title: "Project name",
            prompt: "How would you like to name your project?",
            description: "It'll be used to create your generated project",
            collapseOnAnswer: true,
            validationRules: [NonEmptyValidationRule(error: "Project name cannot be empty.")]
        )
        print("The component returned: \(input)")
    }
}
