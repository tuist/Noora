---
title: Progress bar
titleTemplate: ":title · Step · Noora · Tuist"
description: A component to represent a progress bar step
---

# Progress bar

This component represents a long-running step in the execution of a command showing the current progress and the time it took to complete, once finished.

| Property | Value |
| --- | --- |
| Interactivity | Non-required. The component supports non-interactive mode. |

## Demo

### Interactive

![It shows the execution of a command with an interactive progress bar step](/components/step/progress-bar/interactive.gif)

### Non-interactive

![It shows the execution of a command with a non-interactive progress bar step](/components/step/progress-bar/non-interactive.gif)

## API

### Example

```swift
try await Noora().progressStep(
    message: "Processing the graph",
    successMessage: "Project graph processed",
    errorMessage: "Failed to process the project graph"
) { updateProgress in
    for step in steps {
        try await runStep()
        // Use updateProgress to update the progress. The value should be between 0 and 1.
        updateProgress(step / steps)
    }
}
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `message` | The message to show to the user | Yes | |
| `successMessage` | The message to show to the user when the step is successful | No | |
| `errorMessage` | The message to show to the user when the step fails | No | |
| `task` | The task to execute | Yes | |
