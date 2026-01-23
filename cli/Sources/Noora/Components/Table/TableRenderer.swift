import Foundation
import Logging

/// Shared table rendering functionality used by all table components
struct TableRenderer {
    /// Calculate column widths based on content and constraints
    func calculateLayout(
        data: TableData,
        style: TableStyle,
        terminal: Terminaling
    ) -> TableLayout {
        var columnWidths = Array(repeating: 0, count: data.columns.count)
        let terminalWidth = terminal.size()?.columns ?? 80
        let borderOverhead = data.columns.count + 1
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
                let headerWidth = column.title.displayWidth
                let maxContentWidth = data.rows.map { $0[index].displayWidth }.max() ?? 0
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

    /// Render a border line
    func renderBorder(
        _ position: BorderPosition,
        layout: TableLayout,
        style: TableStyle,
        theme: Theme,
        terminal: Terminaling
    ) -> String {
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

    /// Format a cell with proper width and alignment
    func formatCell(
        _ content: TerminalText,
        width: Int,
        alignment: TableColumn.Alignment,
        theme: Theme,
        terminal: Terminaling
    ) -> String {
        let text = content.plain()
        let textWidth = text.displayWidth
        let formatted = content.formatted(theme: theme, terminal: terminal)

        // Handle text that's too long
        if textWidth > width {
            let truncated = text.truncated(toDisplayWidth: max(0, width - 1)) + "…"
            return TerminalText(stringLiteral: truncated).formatted(theme: theme, terminal: terminal)
        }

        // Apply alignment
        let padding = width - textWidth
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

    /// Render a data row
    func renderRow(
        _ cells: [TerminalText],
        layout: TableLayout,
        style: TableStyle,
        theme: Theme,
        terminal: Terminaling,
        columns: [TableColumn],
        isHeader _: Bool = false
    ) -> String {
        var parts: [String] = []
        let chars = style.borderCharacters
        let borderColor = theme.muted
        let padding = String(repeating: " ", count: style.cellPadding)

        // Left border
        parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal))

        // Cells
        for (index, cell) in cells.enumerated() {
            let width = layout.columnWidths[index]
            let alignment = columns[index].alignment

            // Format cell content with alignment
            let formatted = formatCell(
                cell,
                width: width,
                alignment: alignment,
                theme: theme,
                terminal: terminal
            )

            parts.append(padding)
            parts.append(formatted)
            parts.append(padding)

            // Column separator
            parts.append(chars.vertical.hexIfColoredTerminal(borderColor, terminal))
        }

        return parts.joined()
    }

    /// Render the complete table
    func render(
        data: TableData,
        style: TableStyle,
        theme: Theme,
        terminal: Terminaling,
        logger: Logger?,
        layoutOverride: TableLayout? = nil
    ) -> String {
        guard data.isValid else {
            logger?.warning("Table data is invalid: row cell counts don't match column count")
            return ""
        }

        let layout = layoutOverride ?? calculateLayout(data: data, style: style, terminal: terminal)
        var lines: [String] = []

        // Top border
        lines.append(renderBorder(.top, layout: layout, style: style, theme: theme, terminal: terminal))

        // Headers
        lines.append(renderRow(
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
            lines.append(renderBorder(.middle, layout: layout, style: style, theme: theme, terminal: terminal))
        }

        // Data rows
        for row in data.rows {
            lines.append(renderRow(
                row,
                layout: layout,
                style: style,
                theme: theme,
                terminal: terminal,
                columns: data.columns
            ))
        }

        // Bottom border
        lines.append(renderBorder(.bottom, layout: layout, style: style, theme: theme, terminal: terminal))

        return lines.joined(separator: "\n")
    }
}
