---
title: Updating
titleTemplate: ":title · Tables · Noora · Tuist"
description: A table that re-renders when new data arrives.
---

# Live-updating Table

This component renders tabular data and automatically refreshes whenever new data is emitted from an async source. It's ideal for streaming status dashboards, build logs, or any dataset that changes over time. When paired with the selectable API, users can keep navigating while the table keeps updating.

| Property | Value |
| --- | --- |
| Interactivity | Optional (required for the selectable variant) |

## API

### Basic Example

```swift
let columns = [
    TableColumn(title: "SSID", width: .auto, alignment: .left),
    TableColumn(title: "Signal", width: .auto, alignment: .right)
]

let initial = TableData(
    columns: columns,
    rows: [
        ["Home", "-40 dBm"].map(TerminalText.init)
    ]
)

let updates = AsyncStream<TableData> { continuation in
    wifiScanner.onChange { networks in
        let rows = networks.map { [$0.ssid, "\($0.rssi) dBm"].map(TerminalText.init) }
        continuation.yield(TableData(columns: columns, rows: rows))
    }
}

await Noora().table(initial, updates: updates)
```

### Selectable Updating Example

```swift
let columns = [
    TableColumn(title: "SSID", width: .auto, alignment: .left),
    TableColumn(title: "Signal", width: .auto, alignment: .right),
]

var latest = TableData(columns: columns, rows: [["Home", "-40 dBm"].map(TerminalText.init)])
let updates = AsyncStream<TableData> { continuation in
    Task.detached {
        while !Task.isCancelled {
            latest = makeSnapshot() // Build new TableData from your source
            continuation.yield(latest)
            try? await Task.sleep(for: .seconds(1))
        }
        continuation.finish()
    }
}

let selectedIndex = try await Noora().selectableTable(
    latest,
    updates: updates,
    pageSize: 8
)

let selectedRow = latest.rows[selectedIndex]
print("Picked network: \(selectedRow[0].plain())")
```

### Options

#### Updating table method

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `data` | Initial `TableData` to render | Yes | |
| `updates` | Async sequence emitting `TableData` with the latest rows | Yes | |
| `renderer` | Rendering interface that holds UI state | No | `Renderer()` |

#### Selectable updating table method

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `data` | Initial `TableData` to render | Yes | |
| `updates` | Async sequence emitting `TableData` with the latest rows | Yes | |
| `pageSize` | Number of visible rows | Yes | |
| `renderer` | Rendering interface that holds UI state | No | `Renderer()` |
