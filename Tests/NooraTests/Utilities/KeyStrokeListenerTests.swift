import Testing
@testable import Noora

struct KeyStrokeListenerTests {
    let terminal = MockTerminal(size: .init(rows: 10, columns: 80))
    let keyStrokeListener = KeyStrokeListener()

    @Test func decodes_printable_characters() {
        // When
        let keystrokes = "Hello, World!"
        terminal.characters = Array(keystrokes)

        // Then
        var expectedKeyStrokes = keystrokes.map { KeyStroke.printable($0) }
        var keystrokeCount = 0
        keyStrokeListener.listen(terminal: terminal) { keyStroke in
            keystrokeCount += 1
            #expect(expectedKeyStrokes.removeFirst() == keyStroke)
            return expectedKeyStrokes.isEmpty ? .abort : .continue
        }
        #expect(keystrokeCount == keystrokes.count)
    }

    @Test func decodes_special_keys() {
        // When
        let keystrokes = [
            // Up arrow
            "\u{1B}[A",

            // Down arrow
            "\u{1B}[B",

            // Left arrow
            "\u{1B}[D",

            // Right arrow
            "\u{1B}[C",

            // Backspace
            "\u{08}",

            // Delete
            "\u{7F}",

            // Escape
            "\u{1B}",
        ]
        terminal.characters = keystrokes.flatMap { $0 }

        // Then
        var expectedKeyStrokes: [KeyStroke] = [
            .upArrowKey,
            .downArrowKey,
            .leftArrowKey,
            .rightArrowKey,
            .backspace,
            .delete,
            .escape,
        ]
        var keystrokeCount = 0
        keyStrokeListener.listen(terminal: terminal) { keyStroke in
            keystrokeCount += 1
            #expect(expectedKeyStrokes.removeFirst() == keyStroke)
            return expectedKeyStrokes.isEmpty ? .abort : .continue
        }
        #expect(keystrokeCount == keystrokes.count)
    }

    @Test func decodes_mouse_click_and_motion() {
        // When
        let keystrokes = [
            // Mouse move (2,1)
            "\u{1B}[<35;1;2m",

            // Left mouse down (2,1)
            "\u{1B}[<0;1;2M",

            // Left mouse drag (3,1) -> (4,1)
            "\u{1B}[<32;1;3M",
            "\u{1B}[<32;1;4M",

            // Left mouse up (4,1)
            "\u{1B}[<0;1;4m",

            // Right mouse down (2,1)
            "\u{1B}[<2;1;2M",

            // Right mouse drag (3,1) -> (4,1)
            "\u{1B}[<34;1;3M",
            "\u{1B}[<34;1;4M",

            // Right mouse up (4,1)
            "\u{1B}[<2;1;4m",
        ]
        terminal.characters = keystrokes.flatMap { $0 }

        // Then
        var expectedKeyStrokes: [KeyStroke] = [
            .mouseMoved(position: TerminalPosition(row: 2, column: 1)),
            .leftMouseDown(position: TerminalPosition(row: 2, column: 1)),
            .leftMouseDrag(position: TerminalPosition(row: 3, column: 1)),
            .leftMouseDrag(position: TerminalPosition(row: 4, column: 1)),
            .leftMouseUp(position: TerminalPosition(row: 4, column: 1)),
            .rightMouseDown(position: TerminalPosition(row: 2, column: 1)),
            .rightMouseDrag(position: TerminalPosition(row: 3, column: 1)),
            .rightMouseDrag(position: TerminalPosition(row: 4, column: 1)),
            .rightMouseUp(position: TerminalPosition(row: 4, column: 1)),
        ]
        var keystrokeCount = 0
        keyStrokeListener.listen(terminal: terminal) { keyStroke in
            keystrokeCount += 1
            #expect(expectedKeyStrokes.removeFirst() == keyStroke)
            return expectedKeyStrokes.isEmpty ? .abort : .continue
        }
        #expect(keystrokeCount == keystrokes.count)
    }
}
