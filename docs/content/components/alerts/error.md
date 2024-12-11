---
title: Error
titleTemplate: ":title · Alerts · Noora · Tuist"
description: A component that shows an error alert.
---

# Error Alert

This component is a simple component that shows an error alert to the user.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

## Screenshot

![A screenshot with the error alert](/components/alert/error.png)

## API

### Example

```swift
Noora().error("The project generation failed with.", nextSteps: [
    "Make sure the project manifest files are valid and compile",
    "Ensure you are running the latest Tuist version",
])
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `message` | The error message | Yes | |
| `next` | A list of next steps that the person can take | No | `[]` |
