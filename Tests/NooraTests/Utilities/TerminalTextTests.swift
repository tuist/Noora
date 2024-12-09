import Testing

@testable import Noora

struct TerminalTextTests {
    @Test func commandsAreFormattedBetweenSingleQuotes() {
        // Given
        let subject: TerminalText = "Please run \(.command("tuist project tokens create")) to obtain a new token."

        // When
        let got = subject.description

        // Then
        #expect(got == "Please run 'tuist project tokens create' to obtain a new token.")
    }
}
