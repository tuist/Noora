import ArgumentParser
import Foundation
import Noora

struct FormatCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "format",
        abstract: "A command that showcases text styling using Noora."
    )

    func run() async throws {
        let terminalText = TerminalText("""
        \(.raw("A string with no special semantics in the context of terminal text."))
        \(.command("a-string-that-represents-a-system-command"))
        \(.primary("A string with the theme's primary color"))
        \(.secondary("A string with the theme's secondary color"))
        \(.muted("A string with the theme's muted color"))
        \(.accent("A string with the theme's accent color"))
        \(.danger("A string with the theme's danger color"))
        \(.success("A string with the theme's success color"))
        """)
        let formattedText = Noora().format(terminalText)
        print(formattedText)
    }
}
