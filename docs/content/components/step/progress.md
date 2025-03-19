---
title: Progress
titleTemplate: ":title · Step · Noora · Tuist"
description: A component to represent a progress step
---

# Progress step

This component represents a step in the execution of a command showing the time it took to complete.

| Property | Value |
| --- | --- |
| Interactivity | Non-required. The component supports non-interactive mode. |

## Demo

### Interactive

![It shows the execution of a command with an interactive progress step](/components/step/progress/interactive.gif)

### Non-interactive

![It shows the execution of a command with a non-interactive progress step](/components/step/progress/non-interactive.gif)

## API

### Example

```swift
let graph = try await Noora().progressStep(
    message: "Processing the graph",
    successMessage: "Project graph processed",
    errorMessage: "Failed to process the project graph"
) { updateMessage in
    // An example of an asynchronous task.
    let graph = try await loadGraph()

    // You can use updateMessage to update the progress step message.
    updateMessage("Analyzing the graph")

    // Another asynchronous task.
    try await analyzeGraph(graph)

    return graph
}
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `message` | The message to show to the user | Yes | |
| `successMessage` | The message to show to the user when the step is successful | No | |
| `errorMessage` | The message to show to the user when the step fails | No | |
| `showSpinner` | Whether to show a spinner | No | `true` |
| `task` | The task to execute | Yes | |
