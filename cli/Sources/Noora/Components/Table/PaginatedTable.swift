import Foundation
import Logging

/// A paginated table component for displaying large datasets with navigation
/// Supports both static data (all rows provided upfront) and lazy loading (rows fetched on demand)
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

    /// Total number of pages (required for lazy loading mode, computed from data for static mode)
    let totalPages: Int?

    /// Callback to load a page on demand (nil = static mode, non-nil = lazy loading mode)
    let loadPage: ((Int) async throws -> [TableRow])?

    /// Page cache for lazy loading mode
    private var loadedPages: [Int: [TableRow]] = [:]

    /// Current loading/error state
    enum LoadState: Equatable {
        case idle
        case loading
        case error(String)
    }

    init(
        data: TableData,
        style: TableStyle,
        pageSize: Int,
        renderer: Rendering,
        terminal: Terminaling,
        theme: Theme,
        keyStrokeListener: KeyStrokeListening,
        standardPipelines: StandardPipelines,
        logger: Logger?,
        tableRenderer: TableRenderer,
        totalPages: Int?,
        loadPage: ((Int) async throws -> [TableRow])?
    ) {
        self.data = data
        self.style = style
        self.pageSize = pageSize
        self.renderer = renderer
        self.terminal = terminal
        self.theme = theme
        self.keyStrokeListener = keyStrokeListener
        self.standardPipelines = standardPipelines
        self.logger = logger
        self.tableRenderer = tableRenderer
        self.totalPages = totalPages
        self.loadPage = loadPage
    }

    /// Runs the paginated table with keyboard navigation (static mode)
    func run() throws {
        guard loadPage == nil else {
            logger?.warning("Use runAsync() for lazy loading mode")
            return
        }

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

        let computedTotalPages = data.pageCount(size: pageSize)
        var currentPage = 0

        terminal.inRawMode {
            terminal.withoutCursor {
                // Initial render
                renderStaticPage(currentPage, totalPages: computedTotalPages)

                keyStrokeListener.listen(terminal: terminal) { keyStroke in
                    switch keyStroke {
                    case .rightArrowKey, .printable("n"), .printable(" "):
                        if currentPage < computedTotalPages - 1 {
                            currentPage += 1
                            renderStaticPage(currentPage, totalPages: computedTotalPages)
                        }
                        return .continue

                    case .leftArrowKey, .printable("p"):
                        if currentPage > 0 {
                            currentPage -= 1
                            renderStaticPage(currentPage, totalPages: computedTotalPages)
                        }
                        return .continue

                    case .home:
                        if currentPage != 0 {
                            currentPage = 0
                            renderStaticPage(currentPage, totalPages: computedTotalPages)
                        }
                        return .continue

                    case .end:
                        if currentPage != computedTotalPages - 1 {
                            currentPage = computedTotalPages - 1
                            renderStaticPage(currentPage, totalPages: computedTotalPages)
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

    /// Runs the paginated table with keyboard navigation and lazy loading
    func runAsync() async throws {
        guard let loadPageCallback = loadPage else {
            // Fall back to static mode
            try run()
            return
        }

        guard let knownTotalPages = totalPages, knownTotalPages > 0 else {
            logger?.warning("totalPages is required for lazy loading mode")
            return
        }

        guard terminal.isInteractive else {
            // In non-interactive mode, load and display first page only
            do {
                let firstPageRows = try await loadPageCallback(0)
                let tableData = TableData(columns: data.columns, rows: firstPageRows)
                Table(
                    data: tableData,
                    style: theme.tableStyle,
                    renderer: renderer,
                    standardPipelines: standardPipelines,
                    terminal: terminal,
                    theme: theme,
                    logger: logger,
                    tableRenderer: tableRenderer
                ).run()
            } catch {
                logger?.error("Failed to load page: \(error)")
            }
            return
        }

        var currentPage = 0
        var loadedPagesCache: [Int: [TableRow]] = [:]
        var loadState: LoadState = .idle
        var shouldExit = false
        var lastLayout: TableLayout?

        // Load initial page
        loadState = .loading
        renderLazyPage(
            currentPage,
            totalPages: knownTotalPages,
            rows: nil,
            loadState: loadState,
            lastLayout: nil
        )

        do {
            let rows = try await loadPageCallback(0)
            loadedPagesCache[0] = rows
            loadState = .idle
            lastLayout = renderLazyPage(
                currentPage,
                totalPages: knownTotalPages,
                rows: rows,
                loadState: loadState,
                lastLayout: lastLayout
            )
        } catch {
            loadState = .error(error.localizedDescription)
            renderLazyPage(
                currentPage,
                totalPages: knownTotalPages,
                rows: nil,
                loadState: loadState,
                lastLayout: lastLayout
            )
        }

        terminal.inRawMode {
            terminal.withoutCursor {
                while !shouldExit {
                    keyStrokeListener.listen(terminal: terminal) { keyStroke in
                        switch keyStroke {
                        case .rightArrowKey, .printable("n"), .printable(" "):
                            if case .loading = loadState { return .continue }
                            if currentPage < knownTotalPages - 1 {
                                currentPage += 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .leftArrowKey, .printable("p"):
                            if case .loading = loadState { return .continue }
                            if currentPage > 0 {
                                currentPage -= 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .home:
                            if case .loading = loadState { return .continue }
                            if currentPage != 0 {
                                currentPage = 0
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .end:
                            if case .loading = loadState { return .continue }
                            if currentPage != knownTotalPages - 1 {
                                currentPage = knownTotalPages - 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .printable("r"):
                            // Retry on error
                            if case .error = loadState {
                                loadState = .loading
                                renderLazyPage(
                                    currentPage,
                                    totalPages: knownTotalPages,
                                    rows: nil,
                                    loadState: loadState,
                                    lastLayout: lastLayout
                                )
                                shouldExit = true
                                return .abort
                            }
                            return .continue

                        case .printable("q"), .escape:
                            shouldExit = true
                            return .abort

                        default:
                            return .continue
                        }
                    }

                    // If we exited to load a page, do it now
                    if shouldExit, case .loading = loadState {
                        break
                    }
                }
            }
        }

        // Continue loading pages asynchronously if needed
        while !shouldExit || (loadState == .loading) {
            if case .loading = loadState {
                do {
                    let rows = try await loadPageCallback(currentPage)
                    loadedPagesCache[currentPage] = rows
                    loadState = .idle

                    terminal.inRawMode {
                        terminal.withoutCursor {
                            lastLayout = renderLazyPage(
                                currentPage,
                                totalPages: knownTotalPages,
                                rows: rows,
                                loadState: loadState,
                                lastLayout: lastLayout
                            )
                        }
                    }
                    shouldExit = false
                } catch {
                    loadState = .error(error.localizedDescription)
                    terminal.inRawMode {
                        terminal.withoutCursor {
                            renderLazyPage(
                                currentPage,
                                totalPages: knownTotalPages,
                                rows: nil,
                                loadState: loadState,
                                lastLayout: lastLayout
                            )
                        }
                    }
                    shouldExit = false
                }
            }

            if shouldExit { break }

            // Re-enter the keyboard loop
            terminal.inRawMode {
                terminal.withoutCursor {
                    keyStrokeListener.listen(terminal: terminal) { keyStroke in
                        switch keyStroke {
                        case .rightArrowKey, .printable("n"), .printable(" "):
                            if case .loading = loadState { return .continue }
                            if currentPage < knownTotalPages - 1 {
                                currentPage += 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .leftArrowKey, .printable("p"):
                            if case .loading = loadState { return .continue }
                            if currentPage > 0 {
                                currentPage -= 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .home:
                            if case .loading = loadState { return .continue }
                            if currentPage != 0 {
                                currentPage = 0
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .end:
                            if case .loading = loadState { return .continue }
                            if currentPage != knownTotalPages - 1 {
                                currentPage = knownTotalPages - 1
                                if let cachedRows = loadedPagesCache[currentPage] {
                                    loadState = .idle
                                    lastLayout = renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: cachedRows,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                } else {
                                    loadState = .loading
                                    renderLazyPage(
                                        currentPage,
                                        totalPages: knownTotalPages,
                                        rows: nil,
                                        loadState: loadState,
                                        lastLayout: lastLayout
                                    )
                                    shouldExit = true
                                    return .abort
                                }
                            }
                            return .continue

                        case .printable("r"):
                            if case .error = loadState {
                                loadState = .loading
                                renderLazyPage(
                                    currentPage,
                                    totalPages: knownTotalPages,
                                    rows: nil,
                                    loadState: loadState,
                                    lastLayout: lastLayout
                                )
                                shouldExit = true
                                return .abort
                            }
                            return .continue

                        case .printable("q"), .escape:
                            shouldExit = true
                            return .abort

                        default:
                            return .continue
                        }
                    }
                }
            }
        }
    }

    /// Renders a specific page of the table (static mode)
    private func renderStaticPage(_ page: Int, totalPages: Int) {
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
        let footer = renderStaticPaginationFooter(page: page, totalPages: totalPages)
        lines.append("")
        lines.append(footer)

        // Render everything at once to replace previous content
        let output = lines.joined(separator: "\n")
        renderer.render(output, standardPipeline: standardPipelines.output)
    }

    /// Renders a specific page of the table (lazy loading mode)
    /// - Parameters:
    ///   - page: Current page number (0-indexed)
    ///   - totalPages: Total number of pages
    ///   - rows: Row data to display, or nil for loading/error state
    ///   - loadState: Current loading state
    ///   - lastLayout: Optional layout from previous page to maintain column widths during loading
    /// - Returns: The calculated layout if rows were provided, nil otherwise
    @discardableResult
    private func renderLazyPage(
        _ page: Int,
        totalPages: Int,
        rows: [TableRow]?,
        loadState: LoadState,
        lastLayout: TableLayout? = nil
    ) -> TableLayout? {
        var lines: [String] = []
        var calculatedLayout: TableLayout?

        if let rows {
            let pageData = TableData(columns: data.columns, rows: rows)
            // Calculate layout for this page's data
            calculatedLayout = tableRenderer.calculateLayout(
                data: pageData,
                style: theme.tableStyle,
                terminal: terminal
            )
            let tableOutput = tableRenderer.render(
                data: pageData,
                style: theme.tableStyle,
                theme: theme,
                terminal: terminal,
                logger: logger,
                layoutOverride: calculatedLayout
            )
            lines.append(tableOutput)
        } else {
            // Show placeholder when loading or error, using last known layout if available
            let placeholderRows: [TableRow] = (0 ..< pageSize).map { _ in
                data.columns.map { _ in TerminalText(stringLiteral: "") }
            }
            let pageData = TableData(columns: data.columns, rows: placeholderRows)
            let tableOutput = tableRenderer.render(
                data: pageData,
                style: theme.tableStyle,
                theme: theme,
                terminal: terminal,
                logger: logger,
                layoutOverride: lastLayout
            )
            lines.append(tableOutput)
        }

        // Add footer
        let footer = renderLazyPaginationFooter(page: page, totalPages: totalPages, loadState: loadState)
        lines.append("")
        lines.append(footer)

        // Render everything at once to replace previous content
        let output = lines.joined(separator: "\n")
        renderer.render(output, standardPipeline: standardPipelines.output)

        return calculatedLayout
    }

    /// Renders the pagination footer with navigation instructions (static mode)
    private func renderStaticPaginationFooter(page: Int, totalPages: Int) -> String {
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

    /// Renders the pagination footer with navigation instructions (lazy loading mode)
    private func renderLazyPaginationFooter(page: Int, totalPages: Int, loadState: LoadState) -> String {
        let pageInfo = "Page \(page + 1) of \(totalPages)"

        var statusLine: String
        switch loadState {
        case .idle:
            statusLine = pageInfo
        case .loading:
            statusLine = "\(pageInfo) • Loading..."
        case let .error(message):
            statusLine = "\(pageInfo) • Error: \(message)"
        }

        var controls: [String] = []

        if case .error = loadState {
            controls.append("Retry (r)")
        }

        if case .loading = loadState {
            // No navigation while loading
        } else {
            if page > 0 {
                controls.append("← Previous (p)")
            }
            if page < totalPages - 1 {
                controls.append("Next (n/space) →")
            }
            if totalPages > 2 {
                controls.append("Home/End")
            }
        }
        controls.append("Quit (q/esc)")

        let controlsText = controls.joined(separator: " • ")

        return """
        \(statusLine)
        \(controlsText)
        """.hexIfColoredTerminal(theme.muted, terminal)
    }
}
