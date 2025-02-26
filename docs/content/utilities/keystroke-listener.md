---
title: Keystroke listener
titleTemplate: ":title · Utilities · Noora · Tuist"
description: A utility to listen for keystrokes.
---

# Keystroke listener

When building a CLI, you might need to observe keystrokes,
for example to execute an action as a response to a key press (e.g. before taking the user to the browser for authentication).

Noora provides a utility, `KeyStrokeListener`, which you can use for that:

```swift
let keystrokeListener = KeyStrokeListener()
keystrokeListener.listen { key in
  case key {
    // Match the key you are interested in.
  }
}
```
