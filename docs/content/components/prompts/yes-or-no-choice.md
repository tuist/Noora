---
title: Yes or no choice
titleTemplate: ":title · Prompts · Noora · Tuist"
description: A component that prompts the user to answer a yes or no question.
---

# Yes or no choice

This component is a simple component that prompts the user to answer a yes or no question. It is a good way to get a quick answer from the user.

| Property | Value |
| --- | --- |
| Interactivity | Required (fails otherwise) |

## Demo

![A gif that shows the component in action. The developer uses the key strokes left and right to change their answer from yes to no](/components/prompts/yes-or-no-choice.gif)

## API

### Example

```swift
Noora().yesOrNoChoicePrompt(
  title: "Authentication",
  question: "Would you like to authenticate?",
  defaultAnswer: true,
  description: "Authentication is required to use some CLI features.",
  collapseOnSelection: true,
  theme: theme
)
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `title` | The title of the prompt. | Yes | |
| `question` | The question that the user will answer. | Yes | |
| `defaultAnswer` | The default answer. | No | `true` |
| `description` | A description that provides more context about the question. | No | |
| `collapseOnSelection` | Whether the prompt should collapse after the user selects an option. | No | `true` |
| `theme` | The theme that the prompt should use. | No | `NooraTheme.default` |
| `terminal` | A terminal configuration | No | `Terminal.current` |
