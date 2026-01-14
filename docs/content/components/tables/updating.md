---
title: Updating
titleTemplate: ":title · Tables · Noora · Tuist"
description: A table that re-renders when new data arrives.
---

# Updating Table

This component renders tabular data and automatically refreshes whenever new data is emitted from an async source. It's ideal for streaming status dashboards, build logs, or any dataset that changes over time. When paired with the selectable API, users can keep navigating while the table keeps updating.

| Property | Value |
| --- | --- |
| Interactivity | Required since it re-renders when new data arrives |

## Demo

![A gif that shows the updating table component in action](/components/tables/updating.gif)

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

By default, selection tracks a row key using `rowIDs` when provided, then falling back to the first column's text. Pass `.index` if you prefer the previous behavior of keeping the index fixed during reorders, or `.rowKey` to customize the key.

If you have duplicate names, keep selection stable with `Identifiable` models:

```swift
struct WiFi: Identifiable {
    let id: UUID
    let ssid: String
    let rssi: Int
}

let rows = networks.map { [TerminalText(stringLiteral: $0.ssid), TerminalText(stringLiteral: "\($0.rssi) dBm")] }
let table = TableData(
    columns: columns,
    rows: rows,
    rowIDs: networks.map(\.id)
)

let selectedIndex = try await Noora().selectableTable(
    table,
    updates: updates,
    pageSize: 8
)
let selectedWiFiID = table.rowIDs?[selectedIndex]
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
| `selectionTracking` | Controls whether selection tracks by index or by a row key | No | `.automatic` |
| `renderer` | Rendering interface that holds UI state | No | `Renderer()` |
