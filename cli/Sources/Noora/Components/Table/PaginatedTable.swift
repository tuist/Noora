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
    let logger: Logger

    /// Runs the paginated table with keyboard navigation
    func run() throws {
        guard terminal.isInteractive else {
            // Fall back to static display if not interactive
            let table = Table(
                data: data,
                style: style,
                terminal: terminal,
                theme: theme,
                logger: logger
            )
            let output = table.render()
            renderer.render(output, standardPipeline: StandardPipelines().output)
            return
        }

        guard data.isValid else {
            logger.warning("Table data is invalid: row cell counts don't match column count")
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

        let table = Table(
            data: pageData,
            style: style,
            terminal: terminal,
            theme: theme,
            logger: logger
        )

        let tableOutput = table.render()
        let footer = renderPaginationFooter(page: page, totalPages: totalPages)
        let output = tableOutput + "\n" + footer

        renderer.render(output, standardPipeline: StandardPipelines().output)
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
