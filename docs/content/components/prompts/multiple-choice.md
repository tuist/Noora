---
title: Multiple choice
titleTemplate: ":title · Prompts · Noora · Tuist"
description: A component to select several options among many.
---

# Multiple choice

This component is a simple component that prompts the user to select several option among many.

| Property | Value |
| --- | --- |
| Interactivity | Required (fails otherwise) |

## Demo

![A gif that shows the component in action. The developer uses the key strokes up and down arrows to move their selection and select items](/components/prompts/multiple-choice.gif)

## API

### Example with a case iterable enum

```swift
enum ProjectTargets: String, CaseIterable, CustomStringConvertible {
    case alpha
    case beta
    case gamma
    case delta

    var description: String {
        switch self {
        case .alpha:
            return "Alpha"
        case .beta:
            return "Beta"
        case .gamma:
            return "Gamma"
        case .delta:
            return "Delta"
        }
    }
}

let selection: [ProjectTargets] = Noora(theme: Theme.default).multipleChoicePrompt(
    title: "Migration",
    question: "Select targets for migration to Tuist.",
    description: "You can select up to 3 targets for migration.",
    maxLimit: .limited(count: 3, errorMessage: "You can select up to 3 targets."),
    minLimit: .limited(count: 1, errorMessage: "You need to select at least 1 target.")
)
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `title` | The title of the prompt. | No | |
| `question` | The question that the user will answer. | Yes | |
| `description` | A description that provides more context about the question. | No | |
| `collapseOnSelection` | Whether the prompt should collapse after the user selects an option. | No | `true` |
| `filterMode` | Whether the list of options should be filterable. | No | `disabled` |
| `maxLimit` | Use to limit maximum selected options count. | No | `unlimited` |
| `minLimit` | Use to limit minimum selected options count. | No | `unlimited` |
