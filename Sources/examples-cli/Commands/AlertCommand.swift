import ArgumentParser
import Foundation
import Noora

struct AlertCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "alert",
        abstract: "A command that showcases the alert components."
    )

    func run() async throws {
        Noora().warning(
            .alert(
                "Your token is about to expire",
                nextStep: "Generate a new token with \(.command("tuist project tokens create"))"
            ),
            logger: nil
        )
        print("\n")
        Noora().success(.alert("The project has been successfully initialized", nextSteps: [
            "Run \(.command("tuist registry setup")) to speed up package resolution.",
            "Cache your project targets as binaries with \(.command("tuist cache")).",
        ]), logger: nil)
        print("\n")
        Noora().error(.alert("The project generation failed with.", nextSteps: [
            "Make sure the project manifest files are valid and compile.",
            "Ensure you are running the latest Tuist version.",
        ]), logger: nil)
    }
}
