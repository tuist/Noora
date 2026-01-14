import Foundation
import Logging

/// An interactive table that keeps updating as new data arrives.
struct UpdatingSelectableTable<Updates: AsyncSequence> where Updates.Element == TableData {
    let initialData: TableData
    let updates: Updates
    let style: TableStyle
    let pageSize: Int
    let selectionTracking: TableSelectionTracking
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let terminal: Terminaling
    let theme: Theme
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger?
    let tableRenderer: TableRenderer
    private let renderQueue = DispatchQueue(label: "updating-selectable-table-render")

    func run() async throws -> Int {
        guard terminal.isInteractive else {
            throw NooraError.nonInteractiveTerminal
        }

        guard initialData.isValid else {
            throw NooraError.invalidTableData
        }

        guard !initialData.rows.isEmpty else {
            throw NooraError.emptyTable
        }

        let state = LiveSelectableState(
            data: initialData,
            selectedIndex: 0,
            viewport: TableViewport(
                startIndex: 0,
                size: min(pageSize, initialData.rows.count),
                totalRows: initialData.rows.count
            ),
            selectionTracking: selectionTracking
        )

        let group = DispatchGroup()

        terminal.inRawMode {
            terminal.withoutCursor {
                render(state.snapshot())

                group.enter()
                Task {
                    await consumeUpdates(state: state)
                    group.leave()
                }

                group.enter()
                Task {
                    listenForInput(state: state)
                    group.leave()
                }

                group.wait()
            }
        }

        return try state.result()
    }

    private func consumeUpdates(state: LiveSelectableState) async {
        do {
            for try await newData in updates {
                if Task.isCancelled || state.shouldStop() {
                    break
                }

                guard let snapshot = state.updateData(newData, pageSize: pageSize) else {
                    if !newData.isValid || newData.rows.isEmpty {
                        logger?.warning("Table data is invalid: row cell counts don't match column count")
                    }
                    continue
                }
                render(snapshot)
            }
        } catch {
            logger?.warning("Table updates stream failed: \(error)")
        }
    }

    private func listenForInput(state: LiveSelectableState) {
        keyStrokeListener.listen(terminal: terminal) { keyStroke in
            if state.shouldStop() {
                return .abort
            }

            switch keyStroke {
            case .upArrowKey, .printable("k"):
                if let snapshot = state.moveSelection(delta: -1) {
                    render(snapshot)
                }
                return .continue

            case .downArrowKey, .printable("j"):
                if let snapshot = state.moveSelection(delta: 1) {
                    render(snapshot)
                }
                return .continue

            case .pageUp:
                if let snapshot = state.moveSelection(delta: -pageSize) {
                    render(snapshot)
                }
                return .continue

            case .pageDown:
                if let snapshot = state.moveSelection(delta: pageSize) {
                    render(snapshot)
                }
                return .continue

            case .home:
                if let snapshot = state.moveTo(index: 0) {
                    render(snapshot)
                }
                return .continue

            case .end:
                if let snapshot = state.moveToEnd() {
                    render(snapshot)
                }
                return .continue

            case .returnKey:
                state.selectCurrent()
                return .abort

            case .escape:
                state.cancel()
                return .abort

            default:
                return .continue
            }
        }
    }

    private func render(_ snapshot: LiveSelectableState.Snapshot) {
        let visibleRows = Array(snapshot.data.rows[snapshot.viewport.startIndex ..< snapshot.viewport.endIndex])
        let visibleData = TableData(columns: snapshot.data.columns, rows: visibleRows)
        let selectedInViewport = snapshot.selectedIndex - snapshot.viewport.startIndex

        var lines: [String] = []
        lines.append(renderTableWithSelectionHighlighting(
            data: visibleData,
            selectedIndex: selectedInViewport
        ))
        lines.append("") // Empty line between table and help
        lines.append(renderNavigationHelp(
            selectedIndex: snapshot.selectedIndex,
            totalRows: snapshot.data.rows.count,
            viewport: snapshot.viewport
        ))

        let output = lines.joined(separator: "\n")
        renderQueue.sync {
            renderer.render(output, standardPipeline: standardPipelines.output)
        }
    }

    /// Renders the table with selection highlighting applied
    private func renderTableWithSelectionHighlighting(data: TableData, selectedIndex: Int) -> String {
        guard data.isValid else {
            logger?.warning("Table data is invalid: row cell counts don't match column count")
            return ""
        }

        let layout = tableRenderer.calculateLayout(data: data, style: style, terminal: terminal)
        var lines: [String] = []

        // Top border
        lines.append(tableRenderer.renderBorder(.top, layout: layout, style: style, theme: theme, terminal: terminal))

        // Headers
        lines.append(tableRenderer.renderRow(
            data.columns.map { TerminalText("\(.primary($0.title.plain()))") },
            layout: layout,
            style: style,
            theme: theme,
            terminal: terminal,
            columns: data.columns,
            isHeader: true
        ))

        // Header separator
        if style.headerSeparator {
            lines.append(tableRenderer.renderBorder(.middle, layout: layout, style: style, theme: theme, terminal: terminal))
        }

        // Data rows with selection highlighting
        for (index, row) in data.rows.enumerated() {
            let isSelected = index == selectedIndex
            if isSelected {
                lines.append(renderSelectedRow(
                    row,
                    layout: layout,
                    columns: data.columns
                ))
            } else {
                lines.append(tableRenderer.renderRow(
                    row,
                    layout: layout,
                    style: style,
                    theme: theme,
                    terminal: terminal,
                    columns: data.columns
                ))
            }
        }

        // Bottom border
        lines.append(tableRenderer.renderBorder(.bottom, layout: layout, style: style, theme: theme, terminal: terminal))

        return lines.joined(separator: "\n")
    }

    /// Render a selected row with full-width background highlighting and visible borders
    private func renderSelectedRow(
        _ cells: [TerminalText],
        layout: TableLayout,
        columns: [TableColumn]
    ) -> String {
        var parts: [String] = []
        let chars = style.borderCharacters
        let borderColor = theme.muted

        // Left border (keep the border character but with background)
        parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
            style.selectionColor,
            terminal
        ))

        // Process each cell
        for (index, cell) in cells.enumerated() {
            let width = layout.columnWidths[index]
            let alignment = columns[index].alignment

            // Left padding with background
            let leftPadding = String(repeating: " ", count: style.cellPadding)
            parts.append(leftPadding.onHexIfColoredTerminal(style.selectionColor, terminal))

            // Cell content
            let plainText = cell.plain()
            let truncatedText = plainText.count > width ? String(plainText.prefix(width - 1)) + "…" : plainText

            // Apply alignment and create full-width cell
            let contentPadding = width - truncatedText.count
            let cellContent: String

            switch alignment {
            case .left:
                cellContent = truncatedText + String(repeating: " ", count: contentPadding)
            case .right:
                cellContent = String(repeating: " ", count: contentPadding) + truncatedText
            case .center:
                let leftPad = contentPadding / 2
                let rightPad = contentPadding - leftPad
                cellContent = String(repeating: " ", count: leftPad) + truncatedText + String(repeating: " ", count: rightPad)
            }

            // Apply selection text color on selection background
            parts.append(cellContent.hexIfColoredTerminal(style.selectionTextColor, terminal).onHexIfColoredTerminal(
                style.selectionColor,
                terminal
            ))

            // Right padding with background
            let rightPadding = String(repeating: " ", count: style.cellPadding)
            parts.append(rightPadding.onHexIfColoredTerminal(style.selectionColor, terminal))

            // Column separator (keep the border character but with background)
            if index < cells.count - 1 {
                parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
                    style.selectionColor,
                    terminal
                ))
            }
        }

        // Right border (keep the border character but with background)
        parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
            style.selectionColor,
            terminal
        ))

        return parts.joined()
    }

    /// Renders navigation help text
    private func renderNavigationHelp(
        selectedIndex: Int,
        totalRows: Int,
        viewport _: TableViewport
    ) -> String {
        let currentPage = (selectedIndex / pageSize) + 1
        let totalPages = (totalRows + pageSize - 1) / pageSize

        let status = "Row \(selectedIndex + 1) of \(totalRows)"
        let pageInfo = totalPages > 1 ? " (Page \(currentPage)/\(totalPages))" : ""
        let controls = "↑↓/jk: Navigate, Enter: Select, Esc: Cancel"

        if totalPages > 1 {
            let pageControls = "PgUp/PgDn: Page, Home/End: First/Last"
            return "\(status)\(pageInfo)\n\(controls), \(pageControls)"
                .hexIfColoredTerminal(theme.muted, terminal)
        } else {
            return "\(status)\n\(controls)"
                .hexIfColoredTerminal(theme.muted, terminal)
        }
    }
}

private final class LiveSelectableState {
    struct Snapshot {
        let data: TableData
        let selectedIndex: Int
        let viewport: TableViewport
    }

    private let queue = DispatchQueue(label: "live-selectable-table")
    private let selectionTracking: TableSelectionTracking
    private var data: TableData
    private var selectedIndex: Int
    private var viewport: TableViewport
    private var selectionKey: AnyHashable?
    private var stopped = false
    private var selection: Int?

    init(
        data: TableData,
        selectedIndex: Int,
        viewport: TableViewport,
        selectionTracking: TableSelectionTracking
    ) {
        self.selectionTracking = selectionTracking
        self.data = data
        self.selectedIndex = selectedIndex
        self.viewport = viewport
        selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
    }

    func snapshot() -> Snapshot {
        queue.sync {
            Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func updateData(_ newData: TableData, pageSize: Int) -> Snapshot? {
        queue.sync {
            guard newData.isValid, !newData.rows.isEmpty else { return nil }
            if let matchedIndex = selectionIndex(in: newData) {
                selectedIndex = matchedIndex
            }

            data = newData

            if selectedIndex >= data.rows.count {
                selectedIndex = max(0, data.rows.count - 1)
            }

            viewport = TableViewport(
                startIndex: min(viewport.startIndex, max(0, data.rows.count - 1)),
                size: min(pageSize, data.rows.count),
                totalRows: data.rows.count
            )

            var v = viewport
            v.scrollToShow(selectedIndex)
            viewport = v
            selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)

            return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func moveSelection(delta: Int) -> Snapshot? {
        queue.sync {
            guard !data.rows.isEmpty else { return nil }
            let maxIndex = max(0, data.rows.count - 1)
            selectedIndex = min(max(0, selectedIndex + delta), maxIndex)
            var v = viewport
            v.scrollToShow(selectedIndex)
            viewport = v
            selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
            return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func moveTo(index: Int) -> Snapshot? {
        queue.sync {
            guard !data.rows.isEmpty else { return nil }
            selectedIndex = min(max(index, 0), data.rows.count - 1)
            var v = viewport
            v.scrollToShow(selectedIndex)
            viewport = v
            selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
            return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func moveToEnd() -> Snapshot? {
        queue.sync {
            guard !data.rows.isEmpty else { return nil }
            selectedIndex = data.rows.count - 1
            var v = viewport
            v.scrollToShow(selectedIndex)
            viewport = v
            selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
            return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func selectCurrent() {
        queue.sync {
            stopped = true
            selection = selectedIndex
        }
    }

    func cancel() {
        queue.sync {
            stopped = true
            selection = nil
        }
    }

    func shouldStop() -> Bool {
        queue.sync { stopped }
    }

    func result() throws -> Int {
        try queue.sync {
            guard let selection else {
                throw NooraError.userCancelled
            }
            return selection
        }
    }

    private func selectionKey(for data: TableData, selectedIndex: Int) -> AnyHashable? {
        keyForRow(in: data, index: selectedIndex)
    }

    private func selectionIndex(in data: TableData) -> Int? {
        guard let selectionKey else { return nil }
        switch selectionTracking {
        case .index:
            return nil
        case .rowKey, .automatic:
            for index in data.rows.indices {
                if keyForRow(in: data, index: index) == selectionKey {
                    return index
                }
            }
            return nil
        }
    }

    private func keyForRow(in data: TableData, index: Int) -> AnyHashable? {
        guard data.rows.indices.contains(index) else { return nil }
        switch selectionTracking {
        case .index:
            return nil
        case let .rowKey(selector):
            return selector(data.rows[index])
        case .automatic:
            if let rowIDs = data.rowIDs, rowIDs.indices.contains(index) {
                return rowIDs[index]
            }
            if let firstCell = data.rows[index].first {
                return AnyHashable(firstCell.plain())
            }
            return AnyHashable(data.rows[index].map { $0.plain() })
        }
    }
}
