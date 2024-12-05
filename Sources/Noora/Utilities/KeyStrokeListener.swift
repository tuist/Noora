import Foundation
import Mockable

/// An enum that represents the key strokes supported by the `KeyStrokeListening`
enum KeyStroke {
    /// It represents the return key.
    case returnKey
    /// It represents the q key
    case qKey
    /// It represents the k key
    case kKey
    /// It represents the j key
    case jKey
    /// It represents the y key
    case yKey
    /// It represents the n key
    case nKey
    /// It represents the l key
    case lKey
    /// It represents the h key
    case hKey
    /// It represents the up arrow
    case upArrowKey
    /// It represents the down arrow.
    case downArrowKey
    /// It represents the left arrow
    case leftArrowKey
    /// It represents the right arrow.
    case rightArrowKey
}

/// A result that the caller can use in the onKeyPress callback to instruct the listener on how to
/// proceed.
enum OnKeyPressResult {
    /// The listener exits the loop.
    case abort
    /// The listener continues looping waiting for new characters.
    case `continue`
}

/// A protocol that defines the interface for a utility to observe key strokes.
/// The utility runs a loop waiting for new characters to be received through standard input. When the character is received,
/// it gets mapped to a `KeyStroke` case, and passed to the caller via `onKeyPress`. The caller can then decide if they
/// want to continue receiving notifications, or abort the listening.
@Mockable
protocol KeyStrokeListening {
    /// Listens for new key strokes.
    /// - Parameters:
    ///   - terminal: A terminal instance that the listener uses to subscribe to standard-input characters.
    ///   - onKeyPress: The callback that's invoked when a valid keystroke is parsed.
    func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult)
}

public struct KeyStrokeListener: KeyStrokeListening {
    private var buffer = ""

    func listen(terminal: Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        var buffer = ""

        loop: while let char = terminal.readCharacter() {
            buffer.append(char)

            let keyStroke: KeyStroke? = if char == "q" {
                .qKey
            } else if char == "\n" {
                .returnKey
            } else if char == "k" {
                .kKey
            } else if char == "j" {
                .jKey
            } else if char == "y" {
                .yKey
            } else if char == "n" {
                .nKey
            } else if char == "h" {
                .hKey
            } else if char == "l" {
                .lKey
            } else {
                nil
            }

            if let keyStroke {
                buffer = ""
                switch onKeyPress(keyStroke) {
                case .abort: break loop
                case .continue: continue
                }
            }
            // Escape sequences
            else if buffer == "\u{1B}[A" { // Up arrow
                buffer = ""
                switch onKeyPress(.upArrowKey) {
                case .abort: break loop
                case .continue: continue
                }
            } else if buffer == "\u{1B}[B" { // Down arrow
                buffer = ""
                switch onKeyPress(.downArrowKey) {
                case .abort: break loop
                case .continue: continue
                }
            } else if buffer == "\u{1B}[C" { // Right arrow
                buffer = ""
                switch onKeyPress(.rightArrowKey) {
                case .abort: break loop
                case .continue: continue
                }
            } else if buffer == "\u{1B}[D" { // Left arrow
                buffer = ""
                switch onKeyPress(.leftArrowKey) {
                case .abort: break loop
                case .continue: continue
                }
            } else if buffer.count > 3 {
                buffer = ""
            }
        }
    }
}
