import Foundation
import Logging

/// An interactive table that keeps updating as new data arrives.
struct UpdatingSelectableTable<Updates: AsyncSequence & Sendable> where Updates.Element == TableData {
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

        let renderCoordinator = LiveSelectableRenderer(
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            style: style,
            pageSize: pageSize,
            logger: logger,
            tableRenderer: tableRenderer
        )

        terminal.inRawMode {
            terminal.withoutCursor {
                let semaphore = DispatchSemaphore(value: 0)
                Task {
                    defer { semaphore.signal() }
                    await Self.runLoop(
                        state: state,
                        renderer: renderCoordinator,
                        updates: updates,
                        keyStrokeListener: keyStrokeListener,
                        terminal: terminal,
                        pageSize: pageSize,
                        logger: logger
                    )
                }
                semaphore.wait()
            }
        }

        return try await state.result()
    }

    private enum RunnerResult {
        case updates
        case input
    }

    private static func runLoop(
        state: LiveSelectableState,
        renderer: LiveSelectableRenderer,
        updates: Updates,
        keyStrokeListener: KeyStrokeListening,
        terminal: Terminaling,
        pageSize: Int,
        logger: Logger?
    ) async {
        await renderer.render(snapshot: await state.snapshot())

        await withTaskGroup(of: RunnerResult.self) { group in
            group.addTask {
                await consumeUpdates(
                    state: state,
                    renderer: renderer,
                    updates: updates,
                    pageSize: pageSize,
                    logger: logger
                )
                return .updates
            }

            group.addTask {
                await listenForInput(
                    state: state,
                    renderer: renderer,
                    keyStrokeListener: keyStrokeListener,
                    terminal: terminal,
                    pageSize: pageSize
                )
                return .input
            }

            while let result = await group.next() {
                switch result {
                case .updates:
                    continue
                case .input:
                    group.cancelAll()
                    return
                }
            }
        }
    }

    private static func consumeUpdates(
        state: LiveSelectableState,
        renderer: LiveSelectableRenderer,
        updates: Updates,
        pageSize: Int,
        logger: Logger?
    ) async {
        do {
            for try await newData in updates {
                if Task.isCancelled {
                    break
                }

                if await state.shouldStop() {
                    break
                }

                guard let snapshot = await state.updateData(newData, pageSize: pageSize) else {
                    if !newData.isValid || newData.rows.isEmpty {
                        logger?.warning("Table data is invalid: row cell counts don't match column count")
                    }
                    continue
                }

                await renderer.render(snapshot: snapshot)
            }
        } catch {
            logger?.warning("Table updates stream failed: \(error)")
        }
    }

    private static func listenForInput(
        state: LiveSelectableState,
        renderer: LiveSelectableRenderer,
        keyStrokeListener: KeyStrokeListening,
        terminal: Terminaling,
        pageSize: Int
    ) async {
        let keyStrokes = keyStrokeStream(keyStrokeListener: keyStrokeListener, terminal: terminal)

        for await keyStroke in keyStrokes {
            if await state.shouldStop() {
                break
            }

            switch keyStroke {
            case .upArrowKey, .printable("k"):
                if let snapshot = await state.moveSelection(delta: -1) {
                    await renderer.render(snapshot: snapshot)
                }

            case .downArrowKey, .printable("j"):
                if let snapshot = await state.moveSelection(delta: 1) {
                    await renderer.render(snapshot: snapshot)
                }

            case .pageUp:
                if let snapshot = await state.moveSelection(delta: -pageSize) {
                    await renderer.render(snapshot: snapshot)
                }

            case .pageDown:
                if let snapshot = await state.moveSelection(delta: pageSize) {
                    await renderer.render(snapshot: snapshot)
                }

            case .home:
                if let snapshot = await state.moveTo(index: 0) {
                    await renderer.render(snapshot: snapshot)
                }

            case .end:
                if let snapshot = await state.moveToEnd() {
                    await renderer.render(snapshot: snapshot)
                }

            case .returnKey:
                await state.selectCurrent()
                return

            case .escape:
                await state.cancel()
                return

            default:
                continue
            }
        }
    }

    private static func keyStrokeStream(
        keyStrokeListener: KeyStrokeListening,
        terminal: Terminaling
    ) -> AsyncStream<KeyStroke> {
        AsyncStream { continuation in
            let task = Task.detached {
                keyStrokeListener.listen(terminal: terminal) { keyStroke in
                    continuation.yield(keyStroke)
                    switch keyStroke {
                    case .returnKey, .escape:
                        continuation.finish()
                        return .abort
                    default:
                        return .continue
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

private actor LiveSelectableRenderer {
    private let renderer: Rendering
    private let standardPipelines: StandardPipelines
    private let terminal: Terminaling
    private let theme: Theme
    private let style: TableStyle
    private let pageSize: Int
    private let logger: Logger?
    private let tableRenderer: TableRenderer

    init(
        renderer: Rendering,
        standardPipelines: StandardPipelines,
        terminal: Terminaling,
        theme: Theme,
        style: TableStyle,
        pageSize: Int,
        logger: Logger?,
        tableRenderer: TableRenderer
    ) {
        self.renderer = renderer
        self.standardPipelines = standardPipelines
        self.terminal = terminal
        self.theme = theme
        self.style = style
        self.pageSize = pageSize
        self.logger = logger
        self.tableRenderer = tableRenderer
    }

    func render(snapshot: LiveSelectableState.Snapshot) {
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
        renderer.render(output, standardPipeline: standardPipelines.output)
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
        _ cells: TableRow,
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

private actor LiveSelectableState {
    struct Snapshot: Sendable {
        let data: TableData
        let selectedIndex: Int
        let viewport: TableViewport
    }

    private let selectionTracking: TableSelectionTracking
    private var data: TableData
    private var selectedIndex: Int
    private var viewport: TableViewport
    private var selectionKey: TableRowID?
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
        selectionKey = Self.selectionKey(
            for: data,
            selectedIndex: selectedIndex,
            selectionTracking: selectionTracking
        )
    }

    func snapshot() -> Snapshot {
        Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
    }

    func updateData(_ newData: TableData, pageSize: Int) -> Snapshot? {
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

    func moveSelection(delta: Int) -> Snapshot? {
        guard !data.rows.isEmpty else { return nil }
        let maxIndex = max(0, data.rows.count - 1)
        selectedIndex = min(max(0, selectedIndex + delta), maxIndex)
        var v = viewport
        v.scrollToShow(selectedIndex)
        viewport = v
        selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
        return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
    }

    func moveTo(index: Int) -> Snapshot? {
        guard !data.rows.isEmpty else { return nil }
        selectedIndex = min(max(index, 0), data.rows.count - 1)
        var v = viewport
        v.scrollToShow(selectedIndex)
        viewport = v
        selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
        return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
    }

    func moveToEnd() -> Snapshot? {
        guard !data.rows.isEmpty else { return nil }
        selectedIndex = data.rows.count - 1
        var v = viewport
        v.scrollToShow(selectedIndex)
        viewport = v
        selectionKey = selectionKey(for: data, selectedIndex: selectedIndex)
        return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
    }

    func selectCurrent() {
        stopped = true
        selection = selectedIndex
    }

    func cancel() {
        stopped = true
        selection = nil
    }

    func shouldStop() -> Bool {
        stopped
    }

    func result() throws -> Int {
        guard let selection else {
            throw NooraError.userCancelled
        }
        return selection
    }

    private static func selectionKey(for data: TableData, selectedIndex: Int, selectionTracking: TableSelectionTracking)
        -> TableRowID?
    {
        keyForRow(in: data, index: selectedIndex, selectionTracking: selectionTracking)
    }

    private static func keyForRow(
        in data: TableData,
        index: Int,
        selectionTracking: TableSelectionTracking
    ) -> TableRowID? {
        guard data.rows.indices.contains(index) else { return nil }
        switch selectionTracking {
        case .index:
            return nil
        case let .rowKey(selector):
            return selector(data.rows[index])
        case .automatic:
            return data.rows[index].id
        }
    }

    private func selectionKey(for data: TableData, selectedIndex: Int) -> TableRowID? {
        keyForRow(in: data, index: selectedIndex)
    }

    private func selectionIndex(in data: TableData) -> Int? {
        guard let selectionKey else { return nil }
        switch selectionTracking {
        case .index:
            return nil
        case .rowKey, .automatic:
            for index in data.rows.indices where keyForRow(in: data, index: index) == selectionKey {
                return index
            }
            return nil
        }
    }

    private func keyForRow(in data: TableData, index: Int) -> TableRowID? {
        Self.keyForRow(in: data, index: index, selectionTracking: selectionTracking)
    }
}
