import Testing

@testable import Noora

struct SignalBehaviorTests {
    @Test func restoreCursorIfNeeded_restoreAndExit_restores_cursor() {
        // Given
        let behavior = SignalBehavior.restoreAndExit
        var output: String?

        // When
        behavior.restoreCursorIfNeeded { output = $0 }

        // Then
        #expect(output == "\u{1B}[?25h")
    }

    @Test func restoreCursorIfNeeded_restoreOnly_restores_cursor() {
        // Given
        let behavior = SignalBehavior.restoreOnly
        var output: String?

        // When
        behavior.restoreCursorIfNeeded { output = $0 }

        // Then
        #expect(output == "\u{1B}[?25h")
    }

    @Test func restoreCursorIfNeeded_none_does_nothing() {
        // Given
        let behavior = SignalBehavior.none
        var output: String?

        // When
        behavior.restoreCursorIfNeeded { output = $0 }

        // Then
        #expect(output == nil)
    }

    @Test func terminal_default_signalBehavior_is_restoreAndExit() {
        // Given
        let terminal = MockTerminal()

        // Then
        #expect(terminal.signalBehavior == .restoreAndExit)
    }

    @Test func terminal_signalBehavior_can_be_set_to_restoreOnly() {
        // Given
        let terminal = MockTerminal(signalBehavior: .restoreOnly)

        // Then
        #expect(terminal.signalBehavior == .restoreOnly)
    }

    @Test func terminal_signalBehavior_can_be_set_to_none() {
        // Given
        let terminal = MockTerminal(signalBehavior: .none)

        // Then
        #expect(terminal.signalBehavior == .none)
    }
}
