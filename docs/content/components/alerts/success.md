---
title: Success
titleTemplate: ":title · Alerts · Noora · Tuist"
description: A component that shows a success alert.
---

# Success Alert

This component is a simple component that shows a success alert to the user.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

## Screenshot

![A screenshot that shows the looking of the success alert](/components/alert/success.png)

## API

### Example

```swift
Noora().success("The project has been successfully initialized", nextSteps: [
  "Run \(.command("tuist registry setup")) to speed up package resolution",
  "Cache your project targets as binaries with \(.command("tuist cache"))",
])
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `message` | The success message | Yes | |
| `next` | A list of next steps that the person can take | No | `[]` |
