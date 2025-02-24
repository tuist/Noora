---
title: Text Styling
titleTemplate: ":title · Noora · Tuist"
description: Style terminal output with semantic formatting using TerminalText.
---

# Text Styling

`TerminalText` enables semantic text formatting in terminal output. It adapts to terminal capabilities and themes while maintaining readability.

> [!NOTE]
> We recommend using this API sparingly, only when the semantics of a piece of text are not catered by the  `TerminalText` components.
## API

### Components

| Component | Description |
| --- | --- |
| `.raw(String)` | Text without special formatting |
| `.command(String)` | System commands (e.g. 'tuist generate') |
| `.primary(String)` | Text in theme's primary color |
| `.secondary(String)` | Text in theme's secondary color |
| `.muted(String)` | Text in theme's muted color |
| `.accent(String)` | Text in theme's accent color |
| `.danger(String)` | Text in theme's danger color |
| `.success(String)` | Text in theme's success color |

### Usage

Create styled text using string interpolation:

```swift
let text: TerminalText = """
\(.raw("A string with no special semantics in the context of terminal text."))
\(.command("a-string-that-represents-a-system-command"))
\(.primary("A string with the theme's primary color"))
\(.secondary("A string with the theme's secondary color"))
\(.muted("A string with the theme's muted color"))
\(.accent("A string with the theme's accent color"))
\(.danger("A string with the theme's danger color"))
\(.success("A string with the theme's success color"))
"""

// Format the text for output
let noora = Noora()
let formattedText = noora.format(text)
```

![A screenshot showing styled text in the terminal, with colors and formatting applied based on the TerminalText component used.](/utilities/text-styling.png)

## Examples

### Command Instructions

```swift
let instruction: TerminalText = "Run \(.command("tuist init")) to create a project"
```

### Status Messages

```swift
// Success
let success: TerminalText = "\(.success("✓")) Project \(.primary("MyApp")) created"

// Error
let error: TerminalText = "\(.danger("✗")) \(.command("generate")) failed"

// Prompt
let prompt: TerminalText = "Enter \(.accent("project name")): "
```