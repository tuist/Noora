import Foundation
import Logging

/// An interactive table component that allows row selection with keyboard navigation
struct InteractiveTable {
    let data: TableData
    let style: TableStyle
    let pageSize: Int
    let renderer: Rendering
    let terminal: Terminaling
    let theme: Theme
    let keyStrokeListener: KeyStrokeListening
    let logger: Logger

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
        lines.append(renderInteractiveTableWithSelection(
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
        renderer.render(output, standardPipeline: StandardPipelines().output)
    }

    /// Renders the table with selection highlighting applied
    private func renderInteractiveTableWithSelection(data: TableData, selectedIndex: Int) -> String {
        guard data.isValid else {
            logger.warning("Table data is invalid: row cell counts don't match column count")
            return ""
        }

        let layout = calculateLayoutForData(data)
        var lines: [String] = []

        // Top border
        if true {
            lines.append(renderBorder(.top, layout: layout))
        }

        // Headers
        lines.append(renderRowForInteractive(
            data.columns.map { TerminalText("\(.primary($0.title.plain()))") },
            layout: layout,
            isHeader: true,
            isSelected: false,
            columns: data.columns
        ))

        // Header separator
        if style.headerSeparator, true {
            lines.append(renderBorder(.middle, layout: layout))
        }

        // Data rows with selection highlighting
        for (index, row) in data.rows.enumerated() {
            let isSelected = index == selectedIndex
            lines.append(renderRowForInteractive(
                row,
                layout: layout,
                isSelected: isSelected,
                columns: data.columns
            ))
        }

        // Bottom border
        if true {
            lines.append(renderBorder(.bottom, layout: layout))
        }

        return lines.joined(separator: "\n")
    }

    /// Calculate column widths based on content and constraints for interactive table
    private func calculateLayoutForData(_ data: TableData) -> TableLayout {
        var columnWidths = Array(repeating: 0, count: data.columns.count)
        let terminalWidth = terminal.size()?.columns ?? 80
        let borderOverhead = false ? 0 : (data.columns.count + 1)
        let paddingOverhead = data.columns.count * (style.cellPadding * 2)
        let availableWidth = terminalWidth - borderOverhead - paddingOverhead

        // First pass: calculate minimum widths and handle fixed columns
        var flexibleColumns: [Int] = []
        var usedWidth = 0

        for (index, column) in data.columns.enumerated() {
            switch column.width {
            case let .fixed(width):
                columnWidths[index] = width
                usedWidth += width

            case let .flexible(min, _):
                columnWidths[index] = min
                usedWidth += min
                flexibleColumns.append(index)

            case .auto:
                // Calculate based on content
                let headerWidth = column.title.plain().count
                let maxContentWidth = data.rows.map { $0[index].plain().count }.max() ?? 0
                columnWidths[index] = max(headerWidth, maxContentWidth)
                usedWidth += columnWidths[index]
            }
        }

        // Second pass: distribute remaining width to flexible columns
        let remainingWidth = availableWidth - usedWidth
        if remainingWidth > 0, !flexibleColumns.isEmpty {
            let extraPerColumn = remainingWidth / flexibleColumns.count

            for index in flexibleColumns {
                if case let .flexible(_, max) = data.columns[index].width {
                    let newWidth = columnWidths[index] + extraPerColumn
                    columnWidths[index] = max.map { min(newWidth, $0) } ?? newWidth
                }
            }
        }

        // Ensure columns fit within terminal width
        let totalWidth = columnWidths.reduce(0, +) + borderOverhead + paddingOverhead
        if totalWidth > terminalWidth {
            // Scale down proportionally
            let scale = Double(availableWidth) / Double(columnWidths.reduce(0, +))
            for i in 0 ..< columnWidths.count {
                columnWidths[i] = max(1, Int(Double(columnWidths[i]) * scale))
            }
        }

        return TableLayout(columnWidths: columnWidths)
    }

    /// Render a border line for interactive table
    private func renderBorder(_ position: BorderPosition, layout: TableLayout) -> String {
        let chars = style.borderCharacters
        let borderColor = theme.muted

        var parts: [String] = []

        // Left edge
        switch position {
        case .top: parts.append(chars.topLeft)
        case .middle: parts.append(chars.leftJoin)
        case .bottom: parts.append(chars.bottomLeft)
        }

        // Column separators
        for (index, width) in layout.columnWidths.enumerated() {
            let padding = style.cellPadding * 2
            parts.append(String(repeating: chars.horizontal, count: width + padding))

            if index < layout.columnWidths.count - 1 {
                switch position {
                case .top: parts.append(chars.topJoin)
                case .middle: parts.append(chars.cross)
                case .bottom: parts.append(chars.bottomJoin)
                }
            }
        }

        // Right edge
        switch position {
        case .top: parts.append(chars.topRight)
        case .middle: parts.append(chars.rightJoin)
        case .bottom: parts.append(chars.bottomRight)
        }

        let border = parts.joined()
        return border.hexIfColoredTerminal(borderColor, terminal)
    }

    /// Render a data row for interactive table with selection highlighting
    private func renderRowForInteractive(
        _ cells: [TerminalText],
        layout: TableLayout,
        isHeader: Bool = false,
        isSelected: Bool = false,
        columns: [TableColumn]? = nil
    ) -> String {
        // For selected rows, render with background color while keeping borders visible
        if isSelected, !isHeader {
            return renderSelectedRowWithBorders(cells, layout: layout, columns: columns)
        }

        // Normal row rendering
        var parts: [String] = []
        let chars = style.borderCharacters
        let borderColor = theme.muted
        let padding = String(repeating: " ", count: style.cellPadding)

        // Left border
        if true {
            parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal))
        }

        // Cells
        for (index, cell) in cells.enumerated() {
            let width = layout.columnWidths[index]
            let alignment = (columns ?? data.columns)[index].alignment

            // Format cell content
            let content = cell.formatted(theme: theme, terminal: terminal)

            // Format cell content with alignment
            let plainText = cell.plain()
            let formattedContent: String

            // Handle text that's too long
            if plainText.count > width {
                let truncated = String(plainText.prefix(width - 1)) + "…"
                formattedContent = truncated
            } else {
                // Apply alignment
                let contentPadding = width - plainText.count
                switch alignment {
                case .left:
                    formattedContent = content + String(repeating: " ", count: contentPadding)
                case .right:
                    formattedContent = String(repeating: " ", count: contentPadding) + content
                case .center:
                    let leftPad = contentPadding / 2
                    let rightPad = contentPadding - leftPad
                    formattedContent = String(repeating: " ", count: leftPad) + content + String(repeating: " ", count: rightPad)
                }
            }

            parts.append(padding)
            parts.append(formattedContent)
            parts.append(padding)

            // Column separator
            if index < cells.count - 1, true {
                parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal))
            }
        }

        // Right border
        if true {
            parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal))
        }

        return parts.joined()
    }

    /// Render a selected row with full-width background highlighting and visible borders
    private func renderSelectedRowWithBorders(
        _ cells: [TerminalText],
        layout: TableLayout,
        columns: [TableColumn]?
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
            let alignment = (columns ?? data.columns)[index].alignment

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

    /// Calculate the total width of a row including borders and padding
    private func calculateTotalRowWidth(layout: TableLayout) -> Int {
        var width = 0

        // Left border
        if true {
            width += 1
        }

        // Cells with padding
        for (index, columnWidth) in layout.columnWidths.enumerated() {
            width += style.cellPadding * 2 + columnWidth

            // Column separator
            if index < layout.columnWidths.count - 1, true {
                width += 1
            }
        }

        // Right border
        if true {
            width += 1
        }

        return width
    }

    /// Format a cell for interactive table with proper width and alignment
    private func formatCellForInteractive(
        _ content: TerminalText,
        width: Int,
        alignment: TableColumn.Alignment
    ) -> String {
        let text = content.plain()
        let formatted = content.formatted(theme: theme, terminal: terminal)

        // Handle text that's too long
        if text.count > width {
            let truncated = String(text.prefix(width - 1)) + "…"
            return TerminalText(stringLiteral: truncated).formatted(theme: theme, terminal: terminal)
        }

        // Apply alignment
        let padding = width - text.count
        switch alignment {
        case .left:
            return formatted + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + formatted
        case .center:
            let leftPad = padding / 2
            let rightPad = padding - leftPad
            return String(repeating: " ", count: leftPad) + formatted + String(repeating: " ", count: rightPad)
        }
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

// MARK: - Error Types

public enum NooraError: Error {
    case nonInteractiveTerminal
    case invalidTableData
    case emptyTable
    case userCancelled
}
