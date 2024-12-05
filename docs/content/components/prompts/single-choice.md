---
title: Single choice
titleTemplate: ":title · Prompts · Noora · Tuist"
description: A component to select an option among many.
---

# Single choice

This component is a simple component that prompts the user to select a single option among many.

| Property | Value |
| --- | --- |
| Interactivity | Required (fails otherwise) |

## Demo

![A gif that shows the component in action. The developer uses the key strokes up and down arrows to move their selection](/components/prompts/single-choice.gif)

## API

### Example

```swift
enum ProjectOption: String, CaseIterable, CustomStringConvertible {
    case createTuistProject
    case useExistingXcodeProjectOrWorkspace
    case continueWithoutProject

    var description: String {
        switch self {
        case .createTuistProject:
            return "Create a Tuist project"
        case .useExistingXcodeProjectOrWorkspace:
            return "Add it to an existing Xcode project or workspace"
        case .continueWithoutProject:
            return "Continue without integrating it into a project"
        }
    }
}

Noora().singleChoicePrompt(
    title: "Project",
    question: "Would you like to create a new Tuist project or use an existing Xcode project?",
    description: "Tuist extend the capabilities of your projects.",
    options: ProjectOption.self,
    theme: NooraTheme.tuist()
)
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `title` | The title of the prompt. | Yes | |
| `question` | The question that the user will answer. | Yes | |
| `description` | A description that provides more context about the question. | No | |
| `options` | The options the user can select from. | Yes | |
| `collapseOnSelection` | Whether the prompt should collapse after the user selects an option. | No | `true` |
| `theme` | The theme that the prompt should use. | No | `NooraTheme.default` |
| `terminal` | A terminal configuration | No | `Terminal.current` |
