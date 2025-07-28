---
title: Other
titleTemplate: ":title · Noora · Tuist"
description: Other components.
---

# Other components

This section contains utility components that don't fit into other categories.

## Passthrough

The passthrough component allows you to write text directly to standard output or standard error pipelines with Noora's formatting and styling applied.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

### API

#### Example

```swift
// Write to standard output
Noora().passthrough("Building project...", pipeline: .output)

// Write to standard error
Noora().passthrough("Error: File not found", pipeline: .error)

// Using TerminalText for styled output
let styledText: TerminalText = "Processing \(path: "/path/to/file")..."
Noora().passthrough(styledText, pipeline: .output)
```

#### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `text` | The text to output (can be plain string or TerminalText) | Yes | |
| `pipeline` | The standard pipeline to write to (.output or .error) | Yes | |

### Use Cases

The passthrough component is designed for cases where you want to output text directly to stdout or stderr without wrapping it in any Noora UI components. While it preserves any styling from `TerminalText`, it doesn't add any additional formatting or structure that other Noora components would provide. This is particularly useful when writing tests, as you can use `NooraMock` to capture the output and then run assertions against it, ensuring your text appears correctly.
