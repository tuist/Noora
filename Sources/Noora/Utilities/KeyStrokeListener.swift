import Foundation

/// An enum that represents the key strokes supported by the `KeyStrokeListening`
public enum KeyStroke {
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
            case (_, "\u{1B}[A"): .upArrowKey
            case (_, "\u{1B}[B"): .downArrowKey
            case (_, "\u{1B}[C"): .rightArrowKey
            case (_, "\u{1B}[D"): .leftArrowKey
            case ("\u{08}", _): .backspace
            case ("\u{7F}", _): .delete
            case (_, "\u{1B}"): .escape
            default: nil
            }

            if let keyStroke {
                buffer = ""
                switch onKeyPress(keyStroke) {
                case .abort: break loop
                case .continue: continue
                }
            }
            if buffer.count > 3 {
                buffer = ""
            }
        }
    }
}
