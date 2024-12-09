import ArgumentParser
import Foundation
import Noora

struct CompletionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "completion",
        abstract: "A component to show a completion message."
    )

    func run() async throws {
        Noora(theme: Theme.default).completion(.compound(Set([
            .warning(.string(
                "Your token is about to expire",
                next: "Generate a new token with \(.command("tuist project tokens create"))"
            )),
            .success(.string(
                "The project has been successfully initialized",
                next: "Run \(.command("tuist registry setup")) to speed up package resolution"
            )),
        ])))
    }
}
