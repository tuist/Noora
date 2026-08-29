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

    @Test func clears_unrecognized_complete_escape_sequences_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "4", "~", "a", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.printable("a"), .returnKey])
        #endif
    }

    @Test func maps_ESC_A_to_up_arrow_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "A", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.upArrowKey, .returnKey])
        #endif
    }

    @Test func maps_ESC_B_to_down_arrow_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "B", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.downArrowKey, .returnKey])
        #endif
    }

    @Test func maps_ESC_C_to_right_arrow_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "C", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.rightArrowKey, .returnKey])
        #endif
    }

    @Test func maps_ESC_D_to_left_arrow_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "D", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.leftArrowKey, .returnKey])
        #endif
    }

    @Test func maps_ESC_5_tilde_to_page_up_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "5", "~", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.pageUp, .returnKey])
        #endif
    }

    @Test func maps_ESC_6_tilde_to_page_down_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "6", "~", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.pageDown, .returnKey])
        #endif
    }

    @Test func maps_ESC_H_to_home_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "H", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.home, .returnKey])
        #endif
    }

    @Test func maps_ESC_F_to_end_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "F", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.end, .returnKey])
        #endif
    }

    @Test func maps_newline_to_return_key_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return .abort
            }

            // Then
            #expect(capturedKeyStrokes == [.returnKey])
        #endif
    }

    @Test func maps_printable_characters_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["h", "i", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes == [.printable("h"), .printable("i"), .returnKey])
        #endif
    }

    @Test func discards_oversized_unrecognized_sequence_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["\u{1B}", "[", "1", "2", "3", "4", "5", "6", "7", "a", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return keyStroke == .returnKey ? .abort : .continue
            }

            // Then
            #expect(capturedKeyStrokes.last == .returnKey)
        #endif
    }

    @Test func abort_stops_listening_on_non_windows() {
        #if !os(Windows)
            // Given
            let terminal = MockTerminal()
            terminal.characters = ["a", "b", "c", "\n"]
            let listener = KeyStrokeListener()
            var capturedKeyStrokes = [KeyStroke]()

            // When
            listener.listen(terminal: terminal) { keyStroke in
                capturedKeyStrokes.append(keyStroke)
                return .abort
            }

            // Then
            #expect(capturedKeyStrokes == [.printable("a")])
        #endif
    }
}
