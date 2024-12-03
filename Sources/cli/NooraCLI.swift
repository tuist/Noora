import ArgumentParser
import Foundation
import Rainbow

@main
struct NooraCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command line tool to test the different components available in Noora.",
        subcommands: [SingleChoicePromptCommand.self, YesOrNoChoicePromptCommand.self]
    )
}
