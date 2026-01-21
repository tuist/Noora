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

    /// Initial page to display (0-indexed, defaults to 0)
    let startPage: Int

    /// Callback to load a page on demand (nil = static mode, non-nil = lazy loading mode)
    let loadPage: ((Int) async throws -> [TableRow])?

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
        totalPages: Int? = nil,
        startPage: Int = 0,
        loadPage: ((Int) async throws -> [TableRow])? = nil
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
        self.startPage = startPage
        self.loadPage = loadPage
    }

    // MARK: - Public Entry Points

    /// Runs the paginated table with keyboard navigation (static mode)
    func run() throws {
        guard loadPage == nil else {
            logger?.warning("Use async run() for lazy loading mode")
            return
        }

        guard data.isValid else {
            logger?.warning("Table data is invalid: row cell counts don't match column count")
            return
        }

        let effectiveTotalPages = data.pageCount(size: pageSize)
        guard effectiveTotalPages > 0 else { return }

        // Non-interactive: just display all data
        guard terminal.isInteractive else {
            Table(
                data: data,
                style: theme.tableStyle,
                renderer: renderer,
                standardPipelines: standardPipelines,
                terminal: terminal,
                theme: theme,
                logger: logger,
                tableRenderer: tableRenderer
            ).run()
            return
        }

        // Pre-populate cache with all pages (instant access)
        var cache: [Int: [TableRow]] = [:]
        for page in 0 ..< effectiveTotalPages {
            cache[page] = data.page(at: page, size: pageSize)
        }

        // Run the shared pagination loop
        runPaginationLoop(
            totalPages: effectiveTotalPages,
            initialPage: max(0, min(startPage, effectiveTotalPages - 1)),
            cache: cache,
            loadPageAsync: nil,
            showRowCount: true
        )
    }

    /// Runs the paginated table with keyboard navigation and lazy loading
    func run() async throws {
        guard let loadPageCallback = loadPage else {
            logger?.warning("Use sync run() for static mode")
            return
        }

        guard let knownTotalPages = totalPages, knownTotalPages > 0 else {
            logger?.warning("totalPages is required for lazy loading mode")
            return
        }

        let initialPage = max(0, min(startPage, knownTotalPages - 1))

        // Non-interactive: load and display just the initial page
        guard terminal.isInteractive else {
            do {
                let pageRows = try await loadPageCallback(initialPage)
                let tableData = TableData(columns: data.columns, rows: pageRows)
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

        // Start with empty cache - pages loaded on demand
        var cache: [Int: [TableRow]] = [:]
        var currentPage = initialPage
        var loadState: LoadState = .loading
        var lastLayout: TableLayout?

        // Load initial page
        renderPage(
            page: currentPage,
            totalPages: knownTotalPages,
            rows: nil,
            loadState: loadState,
            lastLayout: nil,
            showRowCount: false
        )

        do {
            let rows = try await loadPageCallback(initialPage)
            cache[initialPage] = rows
            loadState = .idle
            lastLayout = renderPage(
                page: currentPage,
                totalPages: knownTotalPages,
                rows: rows,
                loadState: loadState,
                lastLayout: lastLayout,
                showRowCount: false
            )
        } catch {
            loadState = .error(error.localizedDescription)
            renderPage(
                page: currentPage,
                totalPages: knownTotalPages,
                rows: nil,
                loadState: loadState,
                lastLayout: lastLayout,
                showRowCount: false
            )
        }

        // Main async pagination loop
        var shouldExit = false

        while !shouldExit {
            var pageToLoad: Int?
            var retryRequested = false

            terminal.inRawMode {
                terminal.withoutCursor {
                    keyStrokeListener.listen(terminal: terminal) { keyStroke in
                        let result = handleKeyStroke(
                            keyStroke,
                            currentPage: &currentPage,
                            totalPages: knownTotalPages,
                            cache: cache,
                            loadState: &loadState,
                            lastLayout: &lastLayout,
                            showRowCount: false
                        )

                        switch result {
                        case .continue:
                            return .continue
                        case .exit:
                            shouldExit = true
                            return .abort
                        case let .loadPage(targetPage):
                            pageToLoad = targetPage
                            currentPage = targetPage
                            return .abort
                        case .retry:
                            retryRequested = true
                            return .abort
                        }
                    }
                }
            }

            // Handle async page loading outside the raw mode block
            if let targetPage = pageToLoad {
                loadState = .loading
                renderPage(
                    page: targetPage,
                    totalPages: knownTotalPages,
                    rows: nil,
                    loadState: loadState,
                    lastLayout: lastLayout,
                    showRowCount: false
                )

                do {
                    let rows = try await loadPageCallback(targetPage)
                    cache[targetPage] = rows
                    loadState = .idle
                    lastLayout = renderPage(
                        page: targetPage,
                        totalPages: knownTotalPages,
                        rows: rows,
                        loadState: loadState,
                        lastLayout: lastLayout,
                        showRowCount: false
                    )
                } catch {
                    loadState = .error(error.localizedDescription)
                    renderPage(
                        page: targetPage,
                        totalPages: knownTotalPages,
                        rows: nil,
                        loadState: loadState,
                        lastLayout: lastLayout,
                        showRowCount: false
                    )
                }
            } else if retryRequested {
                loadState = .loading
                renderPage(
                    page: currentPage,
                    totalPages: knownTotalPages,
                    rows: nil,
                    loadState: loadState,
                    lastLayout: lastLayout,
                    showRowCount: false
                )

                do {
                    let rows = try await loadPageCallback(currentPage)
                    cache[currentPage] = rows
                    loadState = .idle
                    lastLayout = renderPage(
                        page: currentPage,
                        totalPages: knownTotalPages,
                        rows: rows,
                        loadState: loadState,
                        lastLayout: lastLayout,
                        showRowCount: false
                    )
                } catch {
                    loadState = .error(error.localizedDescription)
                    renderPage(
                        page: currentPage,
                        totalPages: knownTotalPages,
                        rows: nil,
                        loadState: loadState,
                        lastLayout: lastLayout,
                        showRowCount: false
                    )
                }
            }
        }
    }

    // MARK: - Shared Pagination Loop (for sync/pre-cached mode)

    private func runPaginationLoop(
        totalPages: Int,
        initialPage: Int,
        cache: [Int: [TableRow]],
        loadPageAsync _: ((Int) async throws -> [TableRow])?,
        showRowCount: Bool
    ) {
        var currentPage = initialPage
        var loadState: LoadState = .idle
        var lastLayout: TableLayout?

        // Initial render
        lastLayout = renderPage(
            page: currentPage,
            totalPages: totalPages,
            rows: cache[currentPage],
            loadState: loadState,
            lastLayout: nil,
            showRowCount: showRowCount
        )

        terminal.inRawMode {
            terminal.withoutCursor {
                keyStrokeListener.listen(terminal: terminal) { keyStroke in
                    let result = handleKeyStroke(
                        keyStroke,
                        currentPage: &currentPage,
                        totalPages: totalPages,
                        cache: cache,
                        loadState: &loadState,
                        lastLayout: &lastLayout,
                        showRowCount: showRowCount
                    )

                    switch result {
                    case .continue:
                        return .continue
                    case .exit:
                        return .abort
                    case .loadPage, .retry:
                        // Should never happen in pre-cached mode
                        return .continue
                    }
                }
            }
        }
    }

    // MARK: - Keyboard Handling

    private enum KeyStrokeResult {
        case `continue`
        case exit
        case loadPage(Int)  // Include target page number
        case retry
    }

    private func handleKeyStroke(
        _ keyStroke: KeyStroke,
        currentPage: inout Int,
        totalPages: Int,
        cache: [Int: [TableRow]],
        loadState: inout LoadState,
        lastLayout: inout TableLayout?,
        showRowCount: Bool
    ) -> KeyStrokeResult {
        switch keyStroke {
        case .rightArrowKey, .printable("n"), .printable(" "):
            if case .loading = loadState { return .continue }
            if currentPage < totalPages - 1 {
                currentPage += 1
                return navigateToPage(
                    currentPage,
                    totalPages: totalPages,
                    cache: cache,
                    loadState: &loadState,
                    lastLayout: &lastLayout,
                    showRowCount: showRowCount
                )
            }
            return .continue

        case .leftArrowKey, .printable("p"):
            if case .loading = loadState { return .continue }
            if currentPage > 0 {
                currentPage -= 1
                return navigateToPage(
                    currentPage,
                    totalPages: totalPages,
                    cache: cache,
                    loadState: &loadState,
                    lastLayout: &lastLayout,
                    showRowCount: showRowCount
                )
            }
            return .continue

        case .home:
            if case .loading = loadState { return .continue }
            if currentPage != 0 {
                currentPage = 0
                return navigateToPage(
                    currentPage,
                    totalPages: totalPages,
                    cache: cache,
                    loadState: &loadState,
                    lastLayout: &lastLayout,
                    showRowCount: showRowCount
                )
            }
            return .continue

        case .end:
            if case .loading = loadState { return .continue }
            if currentPage != totalPages - 1 {
                currentPage = totalPages - 1
                return navigateToPage(
                    currentPage,
                    totalPages: totalPages,
                    cache: cache,
                    loadState: &loadState,
                    lastLayout: &lastLayout,
                    showRowCount: showRowCount
                )
            }
            return .continue

        case .printable("r"):
            if case .error = loadState {
                return .retry
            }
            return .continue

        case .printable("q"), .escape:
            return .exit

        default:
            return .continue
        }
    }

    private func navigateToPage(
        _ page: Int,
        totalPages: Int,
        cache: [Int: [TableRow]],
        loadState: inout LoadState,
        lastLayout: inout TableLayout?,
        showRowCount: Bool
    ) -> KeyStrokeResult {
        if let cachedRows = cache[page] {
            loadState = .idle
            lastLayout = renderPage(
                page: page,
                totalPages: totalPages,
                rows: cachedRows,
                loadState: loadState,
                lastLayout: lastLayout,
                showRowCount: showRowCount
            )
            return .continue
        } else {
            // Page not in cache - need to load it
            return .loadPage(page)
        }
    }

    // MARK: - Rendering

    @discardableResult
    private func renderPage(
        page: Int,
        totalPages: Int,
        rows: [TableRow]?,
        loadState: LoadState,
        lastLayout: TableLayout?,
        showRowCount: Bool
    ) -> TableLayout? {
        var lines: [String] = []
        var calculatedLayout: TableLayout?

        if let rows {
            let pageData = TableData(columns: data.columns, rows: rows)
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
            // Show placeholder when loading or error
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
        let footer = renderFooter(
            page: page,
            totalPages: totalPages,
            loadState: loadState,
            showRowCount: showRowCount
        )
        lines.append("")
        lines.append(footer)

        let output = lines.joined(separator: "\n")
        renderer.render(output, standardPipeline: standardPipelines.output)

        return calculatedLayout
    }

    private func renderFooter(
        page: Int,
        totalPages: Int,
        loadState: LoadState,
        showRowCount: Bool
    ) -> String {
        let pageInfo = "Page \(page + 1) of \(totalPages)"

        var statusLine: String
        if showRowCount {
            let rowInfo = "Rows \(page * pageSize + 1)-\(min((page + 1) * pageSize, data.rows.count)) of \(data.rows.count)"
            statusLine = "\(pageInfo) • \(rowInfo)"
        } else {
            switch loadState {
            case .idle:
                statusLine = pageInfo
            case .loading:
                statusLine = "\(pageInfo) • Loading..."
            case let .error(message):
                statusLine = "\(pageInfo) • Error: \(message)"
            }
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
