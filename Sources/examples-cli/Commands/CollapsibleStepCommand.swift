import ArgumentParser
import Foundation
import Noora

struct CollapsibleStep: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "collapsible-step",
        abstract: "A component to show a long-running process that collapses on completion."
    )

    func run() async throws {
        try await Noora().collapsibleStep(
            title: "Authentication",
            successMessage: "Authenticated",
            errorMessage: "Failed to authenticate",
            visibleLines: 5
        ) { progress in
            for i in 0 ..< 20 {
                progress("Progressing \(i)/\(20)")
                try await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
}
