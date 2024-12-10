import Testing

@testable import Noora

struct TerminalTextTests {
    @Test func commandsAreFormattedBetweenSingleQuotes() {
        // Given
        let subject: TerminalText = "Please run \(.command("tuist project tokens create")) to obtain a new token."

        // When
        let got = subject.formatted(theme: .default, terminal: Terminal(isInteractive: false, isColored: true))

        // Then
        #expect(got == "Please run 'tuist project tokens create' to obtain a new token.")
    }
}
