---
title: Keystroke listener
titleTemplate: ":title · Utilities · Noora · Tuist"
description: A utility to listen for keystrokes.
---

# Keystroke listener

When building a CLI, you might need to observe keystrokes,
for example to execute an action as a response to a key press (e.g. before taking the user to the browser for authentication).

## Keyboard Events

You can listen for both printable characters and special keys using the `KeyStrokeListener`.

Raw mode must be enabled for the `KeyStrokeListener` to work properly. This ensures individual keystrokes and special keys are captured correctly. Use the terminal's `inRawMode` method to enable it:

```swift
let terminal = Terminal()
let listener = KeyStrokeListener()

terminal.inRawMode {
    listener.listen(terminal: terminal) { keystroke in
        // Handle keystrokes
    }
}
```

### Example

```swift
let terminal = Terminal()
let listener = KeyStrokeListener()

terminal.inRawMode {
    listener.listen(terminal: terminal) { keystroke in
        switch keystroke {
        case .printable(let char):
            print("Received character: \(char)")
        case .upArrowKey:
            print("Up arrow pressed")
        case .downArrowKey:
            print("Down arrow pressed")
        case .escape:
            return .abort // Stop listening
        default:
            return .continue
        }
        return .continue
    }
}
```

## Mouse Events

To receive mouse events, you need to enable mouse tracking mode. You can do this using the terminal's `withMouseTracking` method.

### Demo

![A gif demonstrating a command line drawing program built using Noora's mouse tracking. The user clicks and drags to draw.](/utilities/mouse-tracking.gif)

### Example

```swift
let terminal = Terminal()
let listener = KeyStrokeListener()

terminal.inRawMode {
    terminal.withMouseTracking(trackMotion: true) {
        listener.listen(terminal: terminal) { keystroke in
            switch keystroke {
            case .leftMouseDown(let position):
                print("Left click at row: \(position.row), column: \(position.column)")
            case .mouseMoved(let position):
                print("Mouse moved to row: \(position.row), column: \(position.column)")
            case .escape:
                return .abort
            default:
                return .continue
            }
            return .continue
        }
    }
}
```

### Mouse Tracking Options

When calling `withMouseTracking`, you can specify:

- `trackMotion: false` (default) - Only receive click events
- `trackMotion: true` - Receive click, drag, and hover events

## Return Value

The keystroke handler must return an `OnKeyPressResult`:

| Value | Description |
| --- | --- |
| `.continue` | Continue listening for more keystrokes |
| `.abort` | Stop listening and exit the loop |

This allows you to control when to stop listening for events, such as when the user presses escape or when you've received all the input you need.
