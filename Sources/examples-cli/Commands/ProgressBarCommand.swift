import ArgumentParser
import Foundation
import Noora

struct ProgressBarCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progress-bar",
        abstract: "A component to shows a progress bar"
    )
    func run() async throws {
        try await Noora().progressBar(
            message: "Loading manifests",
            successMessage: "Manifests loaded",
            errorMessage: "Failed to load manifests",
            total: 100
        ) { _ in
            try await Task.sleep(nanoseconds: 5_000_000_000)
        }
        try await Noora().progressBar(
            message: "Generating Xcode projects and workspace",
            successMessage: "Xcode projects and workspace generated",
            errorMessage: "Failed to generate Xcode workspace and projects",
            total: 200
        ) { _ in
            try await Task.sleep(nanoseconds: 10_000_000_000)
        }
    }
}
