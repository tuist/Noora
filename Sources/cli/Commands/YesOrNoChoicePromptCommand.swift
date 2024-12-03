import ArgumentParser
import Foundation
import Noora

struct YesOrNoChoicePromptCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A component to prompt the user for yes or no."
    )

    func run() async throws {
        let selectedOption = Noora().yesOrNoChoicePrompt(
            title: "Authentication",
            question: "Would you like to authenticate with Tuist?",
            theme: NooraTheme.tuist()
        )
    }
}
