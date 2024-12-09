---
title: Completion
titleTemplate: ":title · Prompts · Noora · Tuist"
description: A component to show completion messages
---

# Completion

This component is a simple component that shows a completion message to the user. This is recommended at the last visual component to show right before completing or aborting the execution of a command.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

## Screenshot

![A screenshot that shows the looking of the completion component](/components/one-off/completion.png)

## API

### Example

```swift
Noora().completion(.compound(Set([
    .warning(.string(
        "Your token is about to expire",
        next: "Generate a new token with \(.command("tuist project tokens create"))"
    )),
    .success(.string(
        "The project has been successfully initialized",
        next: "Run \(.command("tuist registry setup")) to speed up package resolution"
    )),
])))
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `items` | The completion item to present | Yes | |
