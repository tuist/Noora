import Foundation

/// An enum that represents the key strokes supported by the `KeyStrokeListening`
public enum KeyStroke: Equatable {
    case returnKey
    /// It represents the return key.
    /// It represents a printable character key
    case printable(Character)
    /// It represents the up arrow
    case upArrowKey
    /// It represents the down arrow.
    case downArrowKey
    /// It represents the left arrow
    case leftArrowKey
    /// It represents the right arrow.
    case rightArrowKey
    /// It represents the backspace key.
    case backspace
    /// It represents the delete key.
    case delete
    /// It represents the escape key.
    case escape
    /// It represents a left mouse button press.
    case leftMouseDown(position: TerminalPosition)
    /// It represents a right mouse button press.
    case rightMouseDown(position: TerminalPosition)
    /// It represents a left mouse button release.
    case leftMouseUp(position: TerminalPosition)
    /// It represents a right mouse button release.
    case rightMouseUp(position: TerminalPosition)
    /// It represents dragging with left mouse button.
    case leftMouseDrag(position: TerminalPosition)
    /// It represents dragging with right mouse button.
    case rightMouseDrag(position: TerminalPosition)
    /// It represents mouse movement without any buttons pressed.
    case mouseMoved(position: TerminalPosition)
}

/// A result that the caller can use in the onKeyPress callback to instruct the listener on how to
/// proceed.
public enum OnKeyPressResult {
    /// The listener exits the loop.
    case abort
    /// The listener continues looping waiting for new characters.
    case `continue`
}

/// A protocol that defines the interface for a utility to observe key strokes.
/// The utility runs a loop waiting for new characters to be received through standard input. When the character is received,
/// it gets mapped to a `KeyStroke` case, and passed to the caller via `onKeyPress`. The caller can then decide if they
/// want to continue receiving notifications, or abort the listening.
public protocol KeyStrokeListening {
    /// Listens for new key strokes.
    /// - Parameters:
    ///   - terminal: A terminal instance that the listener uses to subscribe to standard-input characters.
    ///   - onKeyPress: The callback that's invoked when a valid keystroke is parsed.
    func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult)
}

public struct KeyStrokeListener: KeyStrokeListening {
    private var buffer = ""

    public init() {}

    public func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        var buffer = ""

        loop: while let char = terminal.readCharacter() {
            buffer.append(char)

            // Handle escape sequences
            if buffer == "\u{1B}",
               let nextChar = terminal.readCharacterNonBlocking()
            {
                buffer.append(nextChar)
            }

            let keyStroke: KeyStroke? = switch (char, buffer) {
            case let (char, _) where buffer.count == 1 && char.isPrintable: .printable(char)
            case let (char, _) where char == "\n": .returnKey
            case (_, "\u{1B}[A"): .upArrowKey
            case (_, "\u{1B}[B"): .downArrowKey
            case (_, "\u{1B}[C"): .rightArrowKey
            case (_, "\u{1B}[D"): .leftArrowKey
            case ("\u{08}", _): .backspace
            case ("\u{7F}", _): .delete
            case (_, "\u{1B}"): .escape
            case let (_, buf) where buf.hasPrefix("\u{1B}[<"): decodeSGRMouseEvent(from: buf)
            default: nil
            }

            if let keyStroke {
                buffer = ""
                switch onKeyPress(keyStroke) {
                case .abort: break loop
                case .continue: continue
                }
            }
            if buffer.count > 14 {
                buffer = ""
            }
        }
    }

    /// Decodes a mouse event in SGR format (ESC[<btn;x;yM or ESC[<btn;x;ym)
    private func decodeSGRMouseEvent(from buffer: String) -> KeyStroke? {
        guard let endIndex = buffer.firstIndex(where: { $0 == "M" || $0 == "m" }) else {
            return nil
        }

        let isPress = buffer[endIndex] == "M"
        let parts = String(buffer.dropFirst(3).prefix(while: { $0 != "M" && $0 != "m" }))
            .split(separator: ";")
            .compactMap { Int($0) }

        guard parts.count == 3 else {
            return nil
        }

        let button = parts[0]
        let position = TerminalPosition(row: parts[2], column: parts[1])

        return switch (button, isPress) {
        case (0, true): .leftMouseDown(position: position)
        case (0, false): .leftMouseUp(position: position)
        case (2, true): .rightMouseDown(position: position)
        case (2, false): .rightMouseUp(position: position)
        case (32, _): .leftMouseDrag(position: position)
        case (34, _): .rightMouseDrag(position: position)
        case (35, _): .mouseMoved(position: position)
        default: nil
        }
    }
}

extension KeyStrokeListening {
    /// Listens for key-strokes notifying the caller by calling the given closure.
    /// - Parameter onKeyPress: Closure to receive key press notifications.
    public func listen(onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        listen(terminal: Terminal(), onKeyPress: onKeyPress)
    }
}
