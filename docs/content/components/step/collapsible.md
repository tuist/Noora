---
title: Collapsible
titleTemplate: ":title · Step · Noora · Tuist"
description: A component to represent a collapsible step
---

# Collapsible step

You can use this component to represent a long-running task that streams output showing only the last lines, and collapsing on completion.
It's useful if you don't want the user to lose the context of the task being executed.

| Property | Value |
| --- | --- |
| Interactivity | Non-required. The component supports non-interactive mode. |


## Demo

### Interactive

![It shows the execution of a command with an interactive collapsible step](/components/step/collapsible/interactive.gif)

### Non-interactive

![It shows the execution of a command with a non-interactive collapsible step](/components/step/collapsible/non-interactive.gif)

## API

### Example

```swift
try await Noora().collapsibleStep(
    title: "Build",
    successMessage: "Build succeeded",
    errorMessage: "Build failed",
    visibleLines: 3
) { progress in
    try await xcodebuild() { progress($0) }
}
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `title` | The title of the underlying task | Yes | |
| `successMessage` | The message to show to the user when the action is successful | No | `nil` |
| `errorMessage` | The message to show to the user when the action fails | No | `nil`|
| `visibleLines` | The number of lines to show from the output | No | `3` |
| `task` | The task to execute | Yes | |
