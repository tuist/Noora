import Testing
@testable import Noora

struct KeyStrokeListenerTests {
    @Test func maps_7F_to_backspace_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{7F}", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.backspace, .returnKey])
        #endif
    }

    @Test func maps_08_to_backspace_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{08}", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.backspace, .returnKey])
        #endif
    }

    @Test func maps_ESC_3_tilde_to_delete_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            // ESC [ 3 ~
            terminal.characters = ["\u{1B}", "[", "3", "~", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.delete, .returnKey])
        #endif
    }
}
