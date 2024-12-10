import ArgumentParser
import Foundation
import Noora

struct AlertCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "alert",
        abstract: "A command that showcases the alert components."
    )

    func run() async throws {
        Noora().warning([
            ("Your token is about to expire", next: "Generate a new token with \(.command("tuist project tokens create"))"),
        ])
        print("\n")
        Noora().success("The project has been successfully initialized", next: [
            "Run \(.command("tuist registry setup")) to speed up package resolution",
            "Cache your project targets as binaries with \(.command("tuist cache"))",
        ])
        print("\n")
        Noora().error("The project generation failed with.", next: [
            "Make sure the project manifest files are valid and compile",
            "Ensure you are running the latest Tuist version",
        ])
    }
}
