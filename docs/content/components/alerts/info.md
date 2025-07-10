---
title: Info
titleTemplate: ":title · Alerts · Noora · Tuist"
description: A component that shows an info alert.
---

# Info Alert

This component shows an info alert to the user.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

## Screenshot

![A screenshot of the info alert](/components/alert/info.png)

## API

### Example

```swift
Noora().info("Your project is using the latest version")

// With takeaways
Noora().info(
  .alert("Your project is using the latest version", takeaways: ["Consider enabling automatic updates with \(.command("tuist config enable-auto-updates"))"])
)
```

### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `message` | The info message to display to the user. | Yes |  |
| `takeaways` | A list of takeaways that provide additional information or next steps. | No | `[]` |