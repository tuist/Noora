import ArgumentParser
import Foundation
import Rainbow

@main
struct ExamplesCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command line tool to test the different components available in Noora.",
        subcommands: [SingleChoicePromptCommand.self, YesOrNoChoicePromptCommand.self, AlertCommand.self, ProgressBarCommand.self]
    )
}
