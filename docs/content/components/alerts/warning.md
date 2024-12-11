---
title: Warning
titleTemplate: ":title · Alerts · Noora · Tuist"
description: A component that shows a warning alert.
---

# Warning Alert

This component shows a warning alert to the user.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

## Screenshot

![A screenshot of the warning alert](/components/alert/warning.png)

## API

### Example

```swift
Noora().warning([
  ("Your token is about to expire", nextSteps: "Generate a new token with \(.command("tuist project tokens create"))"),
])
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `warnings` | A list of warnings, each of which is a message and optionally a next step that the person can take to mitigate the warning. | Yes |  |
