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
            errorMessage: "Failed to load manifests",
            showSpinner: true,
            logger: nil
        ) { _ in
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        try await Noora().progressStep(
            message: "Processing the graph",
            successMessage: "Project graph processed",
            errorMessage: "Failed to process the project graph",
            showSpinner: true,
            logger: nil
        ) { _ in
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        try await Noora().progressStep(
            message: "Generating Xcode projects and workspace",
            successMessage: "Xcode projects and workspace generated",
            errorMessage: "Failed to generate Xcode workspace and projects",
            showSpinner: true,
            logger: nil
        ) { _ in
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}
