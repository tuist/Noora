import ArgumentParser
import Foundation
import Noora

struct ProgressBarStepCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progress-bar",
        abstract: "A component to shows a progress bar"
    )
    func run() async throws {
        try await Noora().progressBarStep(
            message: "Loading manifests",
            successMessage: "Manifests loaded",
            errorMessage: "Failed to load manifests"
        ) { progress in
            let totalSteps = 100
            let stepInterval: UInt64 = 4_000_000_000 / UInt64(totalSteps) // 4 seconds divided by steps

            for step in 0 ... totalSteps {
                let progressValue = Double(step) / Double(totalSteps)
                progress(progressValue)

                if step < totalSteps {
                    try await Task.sleep(nanoseconds: stepInterval)
                }
            }
        }
    }
}
