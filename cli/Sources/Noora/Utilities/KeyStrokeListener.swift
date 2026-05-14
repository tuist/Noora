import Foundation

/// An enum that represents the key strokes supported by the `KeyStrokeListening`
public enum KeyStroke: Sendable, Equatable {
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
    /// Maximum length of a recognised ANSI escape sequence.
    /// Sequences longer than this are silently discarded.
    private static let maxSequenceLength = 8

    public init() {}

    public func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        #if !os(Windows)
            listenUnix(terminal: terminal, onKeyPress: onKeyPress)
        #else
            listenWindows(terminal: terminal, onKeyPress: onKeyPress)
        #endif
    }
}

#if !os(Windows)
    extension KeyStrokeListener {
        private func listenUnix(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
            var buffer = ""

            loop: while let char = terminal.readCharacter() {
                // Ctrl+C — value 3 (ETX)
                if char.unicodeScalars.first?.value == 3 {
                    terminal.signalBehavior.restoreCursorIfNeeded()
                    if terminal.signalBehavior == .restoreAndExit {
                        exit(0)
                    }
                    break loop
                }

                buffer.append(char)
                buffer = readEscapeSequenceIfNeeded(buffer: buffer, terminal: terminal)

                if let keyStroke = mapToKeyStroke(char: char, buffer: buffer) {
                    buffer = ""
                    switch onKeyPress(keyStroke) {
                    case .abort: break loop
                    case .continue: continue
                    }
                }

                // Discard unrecognised sequences to prevent buffer growth.
                if buffer.count > KeyStrokeListener.maxSequenceLength {
                    #if DEBUG
                        fputs("KeyStrokeListener: unrecognized sequence: \(buffer.debugDescription)\n", stderr)
                    #endif
                    buffer = ""
                }
            }
        }

        /// Reads additional characters from the terminal to complete an ANSI escape sequence,
        /// returning the updated buffer. If the buffer doesn't start with ESC, the buffer is
        /// returned unchanged.
        ///
        /// Supported sequence shapes:
        /// - `ESC`                  — standalone Escape key
        /// - `ESC [ <letter>`       — cursor keys: A B C D H F
        /// - `ESC [ <digit> ~`      — special keys: 3~ delete, 5~ pageUp, 6~ pageDown
        ///
        /// The reader is intentionally generic: it keeps consuming non-blocking characters while
        /// the sequence looks incomplete, stopping as soon as `isCompleteEscapeSequence` returns
        /// `true` or the safety cap is reached.
        private func readEscapeSequenceIfNeeded(buffer: String, terminal: Terminaling) -> String {
            guard buffer == "\u{1B}" else { return buffer }

            var result = buffer
            while let next = terminal.readCharacterNonBlocking() {
                result.append(next)
                if isCompleteEscapeSequence(result) { break }
                if result.count >= KeyStrokeListener.maxSequenceLength { break }
            }
            return result
        }

        /// Returns `true` when `buffer` represents a complete, self-contained escape sequence.
        ///
        /// Rules:
        /// - A lone ESC with nothing else readable is complete.
        /// - `ESC [` followed by a letter terminates a CSI sequence (cursor/navigation keys).
        /// - `ESC [` followed by digits and `~` terminates a VT-style special key sequence.
        private func isCompleteEscapeSequence(_ buffer: String) -> Bool {
            guard buffer.hasPrefix("\u{1B}") else { return true }
            guard buffer.count >= 2 else { return false }

            guard buffer.hasPrefix("\u{1B}[") else { return buffer.count >= 2 }

            guard let last = buffer.last else { return false }

            if last.isLetter { return true }

            if last == "~" { return true }

            return false
        }

        /// Maps a raw `(char, buffer)` pair to a `KeyStroke`, or returns `nil` for
        /// unrecognised input.
        ///
        /// Single-character input is matched on `char`; multi-character escape sequences
        /// are matched on the accumulated `buffer`.
        private func mapToKeyStroke(char: Character, buffer: String) -> KeyStroke? {
            // --- Single character ---
            if buffer.count == 1 {
                switch char {
                case "\n": return .returnKey
                case "\u{08}": return .backspace // BS (^H) — some terminals
                case "\u{7F}": return .backspace // DEL — macOS/Linux Backspace key
                case "\u{1B}": return .escape
                default:
                    return char.isPrintable ? .printable(char) : nil
                }
            }

            switch buffer {
            case "\u{1B}[A": return .upArrowKey
            case "\u{1B}[B": return .downArrowKey
            case "\u{1B}[C": return .rightArrowKey
            case "\u{1B}[D": return .leftArrowKey
            case "\u{1B}[3~": return .delete
            case "\u{1B}[5~": return .pageUp
            case "\u{1B}[6~": return .pageDown
            case "\u{1B}[H": return .home
            case "\u{1B}[F": return .end
            default: return nil
            }
        }
    }
#endif

// MARK: - Windows

#if os(Windows)
    extension KeyStrokeListener {
        private enum WindowsKeyCode {
            static let ctrlC: UInt8 = 3
            static let backspace: UInt8 = 8
            static let lineFeed: UInt8 = 10
            static let carriageReturn: UInt8 = 13
            static let escape: UInt8 = 1
            static let home: UInt8 = 71
            static let upArrow: UInt8 = 72
            static let pageUp: UInt8 = 73
            static let leftArrow: UInt8 = 75
            static let rightArrow: UInt8 = 77
            static let end: UInt8 = 79
            static let downArrow: UInt8 = 80
            static let pageDown: UInt8 = 81
            static let delete: UInt8 = 83
        }

        private func listenWindows(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
            loop: while let char = terminal.readRawCharacter() {
                if char == WindowsKeyCode.ctrlC {
                    terminal.signalBehavior.restoreCursorIfNeeded()
                    if terminal.signalBehavior == .restoreAndExit {
                        exit(0)
                    }
                    break loop
                }

                guard let keyStroke = mapWindowsKeyCode(char) else { continue }

                switch onKeyPress(keyStroke) {
                case .abort: break loop
                case .continue: continue
                }
            }
        }

        private func mapWindowsKeyCode(_ code: UInt8) -> KeyStroke? {
            switch code {
            case WindowsKeyCode.escape: return .escape
            case WindowsKeyCode.lineFeed,
                 WindowsKeyCode.carriageReturn: return .returnKey
            case WindowsKeyCode.backspace: return .backspace
            case WindowsKeyCode.home: return .home
            case WindowsKeyCode.upArrow: return .upArrowKey
            case WindowsKeyCode.pageUp: return .pageUp
            case WindowsKeyCode.leftArrow: return .leftArrowKey
            case WindowsKeyCode.rightArrow: return .rightArrowKey
            case WindowsKeyCode.end: return .end
            case WindowsKeyCode.downArrow: return .downArrowKey
            case WindowsKeyCode.pageDown: return .pageDown
            case WindowsKeyCode.delete: return .delete
            default:
                guard let scalar = UnicodeScalar(UInt32(code)),
                      Character(scalar).isPrintable
                else { return nil }
                return .printable(Character(scalar))
            }
        }
    }
#endif

extension KeyStrokeListening {
    /// Listens for key-strokes notifying the caller by calling the given closure.
    /// - Parameter onKeyPress: Closure to receive key press notifications.
    public func listen(onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        listen(terminal: Terminal(), onKeyPress: onKeyPress)
    }
}
