import Foundation
import Logging

/// A paginated table component for displaying large datasets with navigation
struct PaginatedTable {
    let data: TableData
    let style: TableStyle
    let pageSize: Int
    let renderer: Rendering
    let terminal: Terminaling
    let theme: Theme
    let keyStrokeListener: KeyStrokeListening
    let standardPipelines: StandardPipelines
    let logger: Logger?
    let tableRenderer: TableRenderer

    /// Runs the paginated table with keyboard navigation
    func run() throws {
        guard terminal.isInteractive else {
            return Table(
                data: data,
                style: theme.tableStyle,
                renderer: Renderer(),
                standardPipelines: standardPipelines,
                terminal: terminal,
                theme: theme,
                logger: logger,
                tableRenderer: tableRenderer
            )
            .run()
        }

        guard data.isValid else {
            logger?.warning("Table data is invalid: row cell counts don't match column count")
            return
        }

        let totalPages = data.pageCount(size: pageSize)
        var currentPage = 0

        terminal.inRawMode {
            terminal.withoutCursor {
                // Initial render
                renderPage(currentPage, totalPages: totalPages)

                keyStrokeListener.listen(terminal: terminal) { keyStroke in
                    switch keyStroke {
                    case .rightArrowKey, .printable("n"), .printable(" "):
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                            renderPage(currentPage, totalPages: totalPages)
                        }
                        return .continue

                    case .leftArrowKey, .printable("p"):
                        if currentPage > 0 {
                            currentPage -= 1
                            renderPage(currentPage, totalPages: totalPages)
                        }
                        return .continue

                    case .home:
                        if currentPage != 0 {
                            currentPage = 0
                            renderPage(currentPage, totalPages: totalPages)
                        }
                        return .continue

                    case .end:
                        if currentPage != totalPages - 1 {
                            currentPage = totalPages - 1
                            renderPage(currentPage, totalPages: totalPages)
                        }
                        return .continue

                    case .printable("q"), .escape:
                        return .abort

                    default:
                        return .continue
                    }
                }
            }
        }
    }

    /// Renders a specific page of the table
    private func renderPage(_ page: Int, totalPages: Int) {
        let pageRows = data.page(at: page, size: pageSize)
        let pageData = TableData(columns: data.columns, rows: pageRows)

        // Build complete output first
        var lines: [String] = []

        // Get table output by rendering it to a string
        let tableOutput = tableRenderer.render(
            data: pageData,
            style: theme.tableStyle,
            theme: theme,
            terminal: terminal,
            logger: logger
        )
        lines.append(tableOutput)

        // Add footer
        let footer = renderPaginationFooter(page: page, totalPages: totalPages)
        lines.append("")
        lines.append(footer)

        // Render everything at once to replace previous content
        let output = lines.joined(separator: "\n")
        renderer.render(output, standardPipeline: standardPipelines.output)
    }

    /// Renders the pagination footer with navigation instructions
    private func renderPaginationFooter(page: Int, totalPages: Int) -> String {
        let pageInfo = "Page \(page + 1) of \(totalPages)"
        let rowInfo = "Rows \(page * pageSize + 1)-\(min((page + 1) * pageSize, data.rows.count)) of \(data.rows.count)"

        var controls: [String] = []

        if page > 0 {
            controls.append("← Previous (p)")
        }
        if page < totalPages - 1 {
            controls.append("Next (n/space) →")
        }
        if totalPages > 2 {
            controls.append("Home/End")
        }
        controls.append("Quit (q/esc)")

        let controlsText = controls.joined(separator: " • ")

        return """
        \(pageInfo) • \(rowInfo)
        \(controlsText)
        """.hexIfColoredTerminal(theme.muted, terminal)
    }
}
