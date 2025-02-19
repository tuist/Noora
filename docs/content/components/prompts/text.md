---
title: Text
titleTemplate: ":title · Prompts · Noora · Tuist"
description: A component to input text.
---

# Text

You can use this component to prompt the user to input text.

| Property | Value |
| --- | --- |
| Interactivity | Required (fails otherwise) |

## Demo

![A gif that shows the component in action. The developer types the name of the app to create](/components/prompts/text.gif)

## API

### Example

```swift
let response = Noora().textPrompt(
    title: "Project name",
    prompt: "How would you like to name your project?",
    description: "It'll be used to create your generated project",
    collapseOnAnswer: true
)
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `title` | The title of the prompt. | No | |
| `prompt` | The prompt that the user will answer. | Yes | |
| `description` | A description that provides more context about the question. | No | |
| `collapseOnAnswer` | Whether the prompt should collapse after the user inputs text. | No | `true` |
