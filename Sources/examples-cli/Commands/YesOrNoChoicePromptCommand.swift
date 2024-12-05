import ArgumentParser
import Foundation
import Noora

struct YesOrNoChoicePromptCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "yes-or-no-choice-prompt",
        abstract: "A component to prompt the user for yes or no."
    )

    func run() async throws {
        let answer = Noora().yesOrNoChoicePrompt(
            title: "Authentication",
            question: "Would you like to authenticate with Tuist?",
            collapseOnSelection: true,
            theme: NooraTheme.tuist
        )
        print("The component returned: \(answer)")
    }
}
