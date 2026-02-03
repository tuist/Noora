import Foundation

/// An enum that represents the key strokes supported by the `KeyStrokeListening`
public enum KeyStroke: Sendable {
    /// It represents the return key.
    case returnKey
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
    /// It represents the page up key.
    case pageUp
    /// It represents the page down key.
    case pageDown
    /// It represents the home key.
    case home
    /// It represents the end key.
    case end
}

/// A result that the caller can use in the onKeyPress callback to instruct the listener on how to
/// proceed.
public enum OnKeyPressResult: Sendable {
    /// The listener exits the loop.
    case abort
    /// The listener continues looping waiting for new characters.
    case `continue`
}

/// A protocol that defines the interface for a utility to observe key strokes.
/// The utility runs a loop waiting for new characters to be received through standard input. When the character is received,
/// it gets mapped to a `KeyStroke` case, and passed to the caller via `onKeyPress`. The caller can then decide if they
/// want to continue receiving notifications, or abort the listening.
public protocol KeyStrokeListening: Sendable {
    /// Listens for new key strokes.
    /// - Parameters:
    ///   - terminal: A terminal instance that the listener uses to subscribe to standard-input characters.
    ///   - onKeyPress: The callback that's invoked when a valid keystroke is parsed.
    func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult)
}

public struct KeyStrokeListener: KeyStrokeListening {
    #if !os(Windows)
        private var buffer = ""
    #endif

    public init() {}

    // swiftlint:disable:next function_body_length
    public func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        #if !os(Windows)
            var buffer = ""

            loop: while let char = terminal.readCharacter() {
                // Handle Ctrl+C (character code 3) based on terminal's signal behavior
                if char.unicodeScalars.first?.value == 3 {
                    terminal.signalBehavior.restoreCursorIfNeeded()
                    if terminal.signalBehavior == .restoreAndExit {
                        exit(0)
                    }
                    break loop
                }

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
                case (_, "\u{1B}[5~"): .pageUp
                case (_, "\u{1B}[6~"): .pageDown
                case (_, "\u{1B}[H"): .home
                case (_, "\u{1B}[F"): .end
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
        #else
            loop: while let char = terminal.readRawCharacter() {
                // Handle Ctrl+C (character code 3) based on terminal's signal behavior
                // On Windows, Ctrl+C generates character code 3
                // while "getch" is running it doesn't emit a signal
                if char == 3 {
                    terminal.signalBehavior.restoreCursorIfNeeded()
                    if terminal.signalBehavior == .restoreAndExit {
                        exit(0)
                    }
                    break loop
                }

                let keyStroke: KeyStroke?

                switch char {
                case 1: keyStroke = .escape
                case 10, 13: keyStroke = .returnKey // Handle both LF (10) and CR (13) for Windows
                case 8, 14: keyStroke = .backspace // Handle both BS (8) and SO (14)
                case 71: keyStroke = .home
                case 72: keyStroke = .upArrowKey
                case 73: keyStroke = .pageUp
                case 75: keyStroke = .leftArrowKey
                case 77: keyStroke = .rightArrowKey
                case 79: keyStroke = .end
                case 80: keyStroke = .downArrowKey
                case 81: keyStroke = .pageDown
                case 83: keyStroke = .delete
                default:
                    if let scalar = UnicodeScalar(UInt32(char)),
                       Character(scalar).isPrintable
                    {
                        keyStroke = .printable(Character(scalar))
                    } else {
                        keyStroke = nil
                    }
                }

                if let keyStroke {
                    switch onKeyPress(keyStroke) {
                    case .abort: break loop
                    case .continue: continue
                    }
                }
            }
        #endif
    }
}

extension KeyStrokeListening {
    /// Listens for key-strokes notifying the caller by calling the given closure.
    /// - Parameter onKeyPress: Closure to receive key press notifications.
    public func listen(onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        listen(terminal: Terminal(), onKeyPress: onKeyPress)
    }
}
