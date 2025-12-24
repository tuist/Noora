import Foundation
import Logging

/// An interactive table component that allows row selection with keyboard navigation
struct SelectableTable {
    let data: TableData
    let style: TableStyle
    let pageSize: Int
    let renderer: Rendering
    let terminal: Terminaling
    let standardPipelines: StandardPipelines
    let theme: Theme
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger?
    let tableRenderer: TableRenderer

    /// Runs the interactive table and returns the selected row index
    func run() throws -> Int {
        guard terminal.isInteractive else {
            throw NooraError.nonInteractiveTerminal
        }

        guard data.isValid else {
            throw NooraError.invalidTableData
        }

        guard !data.rows.isEmpty else {
            throw NooraError.emptyTable
        }

        var selectedIndex = 0
        var viewport = TableViewport(
            startIndex: 0,
            size: min(pageSize, data.rows.count),
            totalRows: data.rows.count
        )

        var result: Int?

        terminal.inRawMode {
            terminal.withoutCursor {
                // Initial render
                renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)

                // Event loop
                keyStrokeListener.listen(terminal: terminal) { keyStroke in
                    switch keyStroke {
                    case .upArrowKey, .printable("k"):
                        if selectedIndex > 0 {
                            selectedIndex -= 1
                            viewport.scrollToShow(selectedIndex)
                            renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        }
                        return .continue

                    case .downArrowKey, .printable("j"):
                        if selectedIndex < data.rows.count - 1 {
                            selectedIndex += 1
                            viewport.scrollToShow(selectedIndex)
                            renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        }
                        return .continue

                    case .pageUp:
                        selectedIndex = max(0, selectedIndex - pageSize)
                        viewport.scrollToShow(selectedIndex)
                        renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        return .continue

                    case .pageDown:
                        selectedIndex = min(data.rows.count - 1, selectedIndex + pageSize)
                        viewport.scrollToShow(selectedIndex)
                        renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        return .continue

                    case .home:
                        selectedIndex = 0
                        viewport.scrollToShow(selectedIndex)
                        renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        return .continue

                    case .end:
                        selectedIndex = data.rows.count - 1
                        viewport.scrollToShow(selectedIndex)
                        renderTableWithSelection(selectedIndex: selectedIndex, viewport: viewport)
                        return .continue

                    case .returnKey:
                        result = selectedIndex
                        return .abort

                    case .escape:
                        result = -1 // Use -1 to indicate cancellation
                        return .abort

                    default:
                        return .continue
                    }
                }
            }
        }

        let finalResult = result ?? selectedIndex
        if finalResult == -1 {
            throw NooraError.userCancelled
        }
        return finalResult
    }

    /// Renders the table with selection highlighting
    private func renderTableWithSelection(selectedIndex: Int, viewport: TableViewport) {
        // Get visible rows
        let visibleRows = Array(data.rows[viewport.startIndex ..< viewport.endIndex])
        let visibleData = TableData(columns: data.columns, rows: visibleRows)

        // Calculate which row is selected within the visible range
        let selectedInViewport = selectedIndex - viewport.startIndex

        // Build complete output first
        var lines: [String] = []

        // Render table with selection highlighting
        lines.append(renderTableWithSelectionHighlighting(
            data: visibleData,
            selectedIndex: selectedInViewport
        ))

        // Add navigation help
        lines.append("") // Empty line between table and help
        lines.append(renderNavigationHelp(
            selectedIndex: selectedIndex,
            totalRows: data.rows.count,
            viewport: viewport
        ))

        // Render everything at once
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
        _ cells: [TerminalText],
        layout: TableLayout,
        columns: [TableColumn]
    ) -> String {
        var parts: [String] = []
        let chars = style.borderCharacters
        let borderColor = theme.muted

        // Build each segment with proper background color

        // Left border (keep the border character but with background)
        if true {
            parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
                style.selectionColor,
                terminal
            ))
        }

        // Process each cell
        for (index, cell) in cells.enumerated() {
            let width = layout.columnWidths[index]
            let alignment = columns[index].alignment

            // Left padding with background
            let leftPadding = String(repeating: " ", count: style.cellPadding)
            parts.append(leftPadding.onHexIfColoredTerminal(style.selectionColor, terminal))

            // Cell content
            let plainText = cell.plain()
            let truncatedText = plainText.displayWidth > width
                ? plainText.truncated(toDisplayWidth: max(0, width - 1)) + "…"
                : plainText

            // Apply alignment and create full-width cell
            let contentPadding = width - truncatedText.displayWidth
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
            if index < cells.count - 1, true {
                parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
                    style.selectionColor,
                    terminal
                ))
            }
        }

        // Right border (keep the border character but with background)
        if true {
            parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal).onHexIfColoredTerminal(
                style.selectionColor,
                terminal
            ))
        }

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
