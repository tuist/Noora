import ArgumentParser
import Foundation
import Rainbow

@main
struct ExamplesCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command line tool to test the different components available in Noora.",
        subcommands: [
            SingleChoicePromptCommand.self,
            YesOrNoChoicePromptCommand.self,
            TextPromptCommand.self,
            AlertCommand.self,
            ProgressStepCommand.self,
            CollapsibleStep.self,
            FormatCommand.self,
        ]
    )
}
