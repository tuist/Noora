import ArgumentParser
import Foundation
import Noora

struct ProgressStepCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progress-step",
        abstract: "A component to shows a progress step"
    )

    func run() async throws {
        try await Noora().progressStep(
            message: "Loading manifests",
            successMessage: "Manifests loaded",
            errorMessage: "Failed to load manifests"
        ) { _ in
            sleep(2)
        }
        try await Noora().progressStep(
            message: "Processing the graph",
            successMessage: "Project graph processed",
            errorMessage: "Failed to process the project graph"
        ) { _ in
            sleep(2)
        }
        try await Noora().progressStep(
            message: "Generating Xcode projects and workspsace",
            successMessage: "Xcode projects and workspace generated",
            errorMessage: "Failed to generate Xcode workspace and projects"
        ) { _ in
            sleep(2)
        }
    }
}
