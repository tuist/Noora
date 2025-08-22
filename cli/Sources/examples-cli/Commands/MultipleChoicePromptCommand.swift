import ArgumentParser
import Foundation
import Noora

struct MultipleChoicePromptCommand: AsyncParsableCommand {
    enum ProjectTargets: String, CaseIterable, CustomStringConvertible {
        case alpha
        case beta
        case gamma
        case delta

        var description: String {
            switch self {
            case .alpha:
                return "Alpha"
            case .beta:
                return "Beta"
            case .gamma:
                return "Gamma"
            case .delta:
                return "Delta"
            }
        }
    }

    static let configuration = CommandConfiguration(
        commandName: "multiple-choice-prompt",
        abstract: "A component to prompt the user for a multiple choice."
    )

    @Option var filterMode: MultipleChoicePromptFilterMode = .toggleable

    func run() async throws {
        let selection: [ProjectTargets] = Noora(theme: Theme.default).multipleChoicePrompt(
            title: "Migration",
            question: "Select targets for migration to Tuist.",
            description: "You can select up to 3 targets for migration.",
            filterMode: filterMode,
            maxLimit: .limited(count: 3, errorMessage: "You can select up to 3 targets."),
            minLimit: .limited(count: 1, errorMessage: "You need to select at least 1 target.")
        )
        print("The component returned: \(selection)")
    }
}

extension MultipleChoicePromptFilterMode: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        switch argument {
        case "disabled": self = .disabled
        case "toggleable": self = .toggleable
        case "enabled": self = .enabled
        default: return nil
        }
    }
}
