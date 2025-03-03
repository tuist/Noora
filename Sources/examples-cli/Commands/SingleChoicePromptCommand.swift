import ArgumentParser
import Foundation
import Noora

struct SingleChoicePromptCommand: AsyncParsableCommand {
    enum ProjectOption: String, CaseIterable, CustomStringConvertible {
        case createTuistProject
        case useExistingXcodeProjectOrWorkspace
        case continueWithoutProject

        var description: String {
            switch self {
            case .createTuistProject:
                return "Create a Tuist project"
            case .useExistingXcodeProjectOrWorkspace:
                return "Add it to an existing Xcode project or workspace"
            case .continueWithoutProject:
                return "Continue without integrating it into a project"
            }
        }
    }

    static let configuration = CommandConfiguration(
        commandName: "single-choice-prompt",
        abstract: "A component to prompt the user for a single choice."
    )

    @Option var filterMode: SingleChoicePromptFilterMode = .toggleable

    func run() async throws {
        let selection: ProjectOption = Noora(theme: Theme.default).singleChoicePrompt(
            title: "Project",
            question: "Would you like to create a new Tuist project or use an existing Xcode project?",
            description: "Tuist extend the capabilities of your projects.",
            filterMode: filterMode
        )
        print("The component returned: \(selection)")
    }
}

extension SingleChoicePromptFilterMode: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        switch argument {
        case "disabled": self = .disabled
        case "toggleable": self = .toggleable
        case "enabled": self = .enabled
        default: return nil
        }
    }
}
