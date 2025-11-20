import ArgumentParser
import Foundation
import Dispatch
import Noora
import Logging
import Rainbow

struct TableCommand: AsyncParsableCommand {
    enum TableMode: String, CustomStringConvertible, ExpressibleByArgument, EnumerableFlag {
        case simple
        case styled
        case paginated
        case selectable
        case updating
        case selectableUpdating

        var description: String {
            switch self {
            case .simple:
                return "Simple static table"
            case .styled:
                return "Styled table with semantic formatting"
            case .paginated:
                return "Large table with pagination"
            case .selectable:
                return "Interactive table for selection"
            case .updating:
                return "Live-updating table fed by an async sequence"
            case .selectableUpdating:
                return "Live Wi-Fi snapshot with selectable row"
            }
        }
    }

    static let configuration = CommandConfiguration(
        commandName: "table",
        abstract: "A command that showcases table components."
    )

    @Argument
    var tableStyle: TableMode = .simple

    func run() async throws {
        let noora = Noora()

        switch tableStyle {
        case .simple:
            await simpleStaticTable(noora)
        case .styled:
            await styledTable(noora)
        case .paginated:
            try await paginatedTable(noora)
        case .selectable:
            try await selectableTable(noora)
        case .updating:
            await liveUpdatingTable(noora)
        case .selectableUpdating:
            try await selectableUpdatingTable(noora)
        }
    }
}

extension TableCommand {
    private func simpleStaticTable(_ noora: Noora) async {
        let headers = ["Name", "Role", "Status"]
        let rows = [
            ["John Doe", "Developer", "Active"],
            ["Jane Smith", "Designer", "Active"],
            ["Bob Wilson", "Manager", "Inactive"],
            ["Alice Brown", "Tester", "Pending"],
        ]

        noora.table(headers: headers, rows: rows)
    }

    private func styledTable(_ noora: Noora) async {
        let headers = ["File", "Size", "Modified", "Type"]
        let rows = [
            ["README.md", "2.4 KB", "2024-01-15", "md"],
            ["Package.swift", "1.8 KB", "2024-01-14", "swift"],
            ["Sources/", "--", "2024-01-16", "dir"],
            ["Tests/", "--", "2024-01-12", "dir"],
            ["Documentation.md", "15.2 KB", "2024-01-10", "md"],
        ]

        noora.table(headers: headers, rows: rows)
    }

    private func paginatedTable(_ noora: Noora) async throws {
        let headers = ["ID", "Task Name", "Priority", "Assignee", "Due Date"]

        // Generate a large dataset
        let priorities = ["High", "Medium", "Low"]
        let assignees = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
        let tasks = [
            "Implement user authentication",
            "Design database schema",
            "Create REST API endpoints",
            "Write unit tests",
            "Update documentation",
            "Fix memory leak issue",
            "Optimize query performance",
            "Add error handling",
            "Implement caching layer",
            "Review code quality",
        ]

        var rows: [[String]] = []
        for i in 1 ... 50 {
            let task = tasks[i % tasks.count]
            let priority = priorities[i % priorities.count]
            let assignee = assignees[i % assignees.count]
            let dueDate = "2024-0\((i % 9) + 1)-\(String(format: "%02d", (i % 28) + 1))"

            rows.append([
                "\(i)",
                task,
                priority,
                assignee,
                dueDate,
            ])
        }

        try noora.paginatedTable(headers: headers, rows: rows, pageSize: 10)
    }

    private func largTablePreview(_ noora: Noora) async {
        print("   [Preview of large table - first 5 rows]")
        let headers = ["ID", "Task Name", "Priority"]

        let rows = [
            ["1", "Implement user authentication", "High"],
            ["2", "Design database schema", "Medium"],
            ["3", "Create REST API endpoints", "Low"],
            ["4", "Write unit tests", "High"],
            ["5", "Update documentation", "Medium"],
        ]

        noora.table(headers: headers, rows: rows)
        print("   ... (45 more rows would be shown with pagination)")
    }

    private func selectableTable(_ noora: Noora) async throws {
        let headers = ["Language", "Type", "Year", "Popularity", "Description"]

        let languageData = [
            ("Swift", "Compiled", "2014", "High", "Apple's modern language for iOS/macOS development"),
            ("Python", "Interpreted", "1991", "Very High", "Versatile language for data science and web dev"),
            ("JavaScript", "Interpreted", "1995", "Very High", "Essential for web development and Node.js"),
            ("Rust", "Compiled", "2010", "Growing", "Systems programming with memory safety"),
            ("Go", "Compiled", "2009", "High", "Google's language for cloud and networking"),
            ("TypeScript", "Transpiled", "2012", "High", "JavaScript with static type checking"),
            ("Kotlin", "Compiled", "2011", "Medium", "JetBrains' modern alternative to Java"),
            ("C++", "Compiled", "1985", "High", "Powerful systems and game development language"),
            ("Java", "Compiled", "1995", "Very High", "Enterprise and Android development platform"),
            ("C#", "Compiled", "2000", "High", "Microsoft's versatile .NET language"),
            ("Ruby", "Interpreted", "1995", "Medium", "Elegant language popular for web frameworks"),
            ("PHP", "Interpreted", "1995", "High", "Dominant language for web backend development"),
        ]

        let rows = languageData.map { lang, type, year, popularity, description in
            [lang, type, year, popularity, description]
        }

        let selectedIndex = try await noora.selectableTable(headers: headers, rows: rows, pageSize: 8)
        print("Selected row: \(languageData[selectedIndex].0)")
    }

    private func selectableTablePreview(_ noora: Noora) async {
        print("   [Preview of interactive table - first 5 programming languages]")
        let headers = ["Language", "Type", "Year", "Popularity", "Description"]

        let languageData = [
            ("Swift", "Compiled", "2014", "High", "Apple's modern language for iOS/macOS development"),
            ("Python", "Interpreted", "1991", "Very High", "Versatile language for data science and web dev"),
            ("JavaScript", "Interpreted", "1995", "Very High", "Essential for web development and Node.js"),
            ("Rust", "Compiled", "2010", "Growing", "Systems programming with memory safety"),
            ("Go", "Compiled", "2009", "High", "Google's language for cloud and networking"),
        ]

        let rows = languageData.map { lang, type, year, popularity, description in
            [lang, type, year, popularity, description]
        }

        noora.table(headers: headers, rows: rows)
        print("   (In interactive mode, you could navigate with arrows and press Enter to select)")
    }

    private func semanticStyledTable(_ noora: Noora) async {
        // Example using the new semantic styling API
        let styledHeaders: [TableCellStyle] = [
            .primary("User"),
            .accent("Status"),
            .muted("Score"),
            .secondary("Role"),
        ]

        let styledRows: [StyledTableRow] = [
            [.plain("Alice"), .success("Active"), .plain("95"), .plain("Admin")],
            [.plain("Bob"), .warning("Pending"), .plain("87"), .plain("User")],
            [.plain("Charlie"), .danger("Suspended"), .plain("72"), .plain("Moderator")],
            [.plain("Diana"), .success("Active"), .plain("91"), .plain("User")],
            [.plain("Eve"), .muted("Inactive"), .plain("65"), .plain("Guest")],
        ]

        noora.table(headers: styledHeaders, rows: styledRows)
    }

    private func liveUpdatingTable(_ noora: Noora) async {
        let columns = [
            TableColumn(title: "SSID", width: .auto, alignment: .left),
            TableColumn(title: "Signal", width: .auto, alignment: .right),
        ]

        let initial = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-40 dBm")],
        ])

        noora.info("Live-updating Wi-Fi table — press Ctrl+C to exit.")

        var activeNetworks: [String] = ["Home", "Office", "Cafe", "Library", "Station"]
        let baseSignals: [String: Int] = [
            "Home": -40,
            "Office": -65,
            "Cafe": -72,
            "Library": -55,
            "Station": -80,
            "Airport": -70,
            "Bus": -78,
            "Event": -66,
            "Hotel": -62,
        ]

        let updates = AsyncStream<TableData> { continuation in
            Task.detached {
                var rng = SystemRandomNumberGenerator()
                while !Task.isCancelled {
                    // Randomly remove a network (down to at least 2)
                    if activeNetworks.count > 2, Int.random(in: 0 ... 4, using: &rng) == 0 {
                        let dropIndex = Int.random(in: 0 ..< activeNetworks.count, using: &rng)
                        activeNetworks.remove(at: dropIndex)
                    }

                    // Randomly add a new network from the pool
                    let available = baseSignals.keys.filter { !activeNetworks.contains($0) }
                    if !available.isEmpty, Int.random(in: 0 ... 2, using: &rng) == 0 {
                        if let newName = available.randomElement(using: &rng) {
                            activeNetworks.append(newName)
                        }
                    }

                    let jitteredPairs: [(String, Int)] = activeNetworks.compactMap { name in
                        guard let baseRSSI = baseSignals[name] else { return nil }
                        let jitter = Int.random(in: -7 ... 5, using: &rng)
                        return (name, baseRSSI + jitter)
                    }

                    let sorted = jitteredPairs.sorted { $0.1 > $1.1 }
                    let jittered: [[TerminalText]] = sorted.map { name, reading in
                        [
                            TerminalText(stringLiteral: name),
                            TerminalText(stringLiteral: "\(reading) dBm"),
                        ]
                    }

                    continuation.yield(TableData(columns: columns, rows: jittered))

                    do {
                        try await Task.sleep(for: .milliseconds(900))
                    } catch {
                        break
                    }
                }
                continuation.finish()
            }
        }

        await noora.updatingTable(initial, updates: updates)
    }

    private func selectableUpdatingTable(_ noora: Noora) async throws {
        let headers = ["SSID", "Signal"]
        let columns = [
            TableColumn(title: headers[0], width: .auto, alignment: .left),
            TableColumn(title: headers[1], width: .auto, alignment: .right),
        ]

        let seedNetworks: [String] = ["Home", "Office", "Cafe", "Library", "Station"]
        let baseSignals: [String: Int] = [
            "Home": -40,
            "Office": -65,
            "Cafe": -72,
            "Library": -55,
            "Station": -80,
            "Airport": -70,
            "Bus": -78,
            "Event": -66,
            "Hotel": -62,
        ]

        func snapshot(
            active: [String],
            rng: inout SystemRandomNumberGenerator
        ) -> (TableData, [(String, Int)]) {
            let pairs: [(String, Int)] = active.compactMap { name in
                guard let base = baseSignals[name] else { return nil }
                let jitter = Int.random(in: -7 ... 5, using: &rng)
                return (name, base + jitter)
            }

            let sorted = pairs.sorted { $0.1 > $1.1 }
            let rows = sorted.map { name, reading in
                [
                    TerminalText(stringLiteral: name),
                    TerminalText(stringLiteral: "\(reading) dBm"),
                ]
            }

            return (TableData(columns: columns, rows: rows), sorted)
        }

        var rng = SystemRandomNumberGenerator()
        let (initialData, _) = snapshot(active: seedNetworks, rng: &rng)
        noora.info("Live Wi-Fi scan (updates). Use arrows/Enter to pick while it updates. Esc to cancel.")

        let updates = AsyncStream<TableData> { continuation in
            let producer = Task {
                var rng = rng
                var active = seedNetworks

                while !Task.isCancelled {
                    if active.count > 2, Int.random(in: 0 ... 4, using: &rng) == 0 {
                        active.remove(at: Int.random(in: 0 ..< active.count, using: &rng))
                    }

                    let available = baseSignals.keys.filter { !active.contains($0) }
                    if !available.isEmpty, Int.random(in: 0 ... 2, using: &rng) == 0,
                       let newName = available.randomElement(using: &rng) {
                        active.append(newName)
                    }

                    let (tableData, _) = snapshot(active: active, rng: &rng)
                    continuation.yield(tableData)

                    do {
                        try await Task.sleep(for: .milliseconds(900))
                    } catch {
                        break
                    }
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                producer.cancel()
            }
        }

        let runner = LiveSelectableUpdatingRunner(
            columns: columns,
            initialData: initialData,
            updates: updates,
            pageSize: 8,
            terminal: Terminal(),
            keyListener: KeyStrokeListener(),
            renderer: Renderer(),
            theme: Theme.default,
            tableStyle: TableStyle(theme: Theme.default)
        )

        let selected = try await runner.run()
        print("Selected network: \(selected.name) (\(selected.signal) dBm)")
    }
}

private struct LiveSelectableUpdatingRunner<Updates: AsyncSequence> where Updates.Element == TableData {
    let columns: [TableColumn]
    let initialData: TableData
    let updates: Updates
    let pageSize: Int
    let terminal: Terminal
    let keyListener: KeyStrokeListener
    let renderer: Renderer
    let theme: Theme
    let tableStyle: TableStyle
    let standardPipelines = StandardPipelines()
    private let renderQueue = DispatchQueue(label: "live-selectable-render")

    func run() async throws -> (name: String, signal: Int) {
        guard terminal.isInteractive else { throw NooraError.nonInteractiveTerminal }
        guard initialData.isValid, !initialData.rows.isEmpty else { throw NooraError.invalidTableData }

        let state = LiveSelectableState(
            data: initialData,
            selectedIndex: 0,
            viewport: TableViewport(
                startIndex: 0,
                size: min(pageSize, initialData.rows.count),
                totalRows: initialData.rows.count
            )
        )

        let group = DispatchGroup()

        terminal.inRawMode {
            terminal.withoutCursor {
                render(state.snapshot())

                group.enter()
                Task {
                    for try await newData in updates {
                        if state.shouldStop() { break }
                        guard let snap = state.updateData(newData, pageSize: pageSize) else { continue }
                        render(snap)
                    }
                    group.leave()
                }

                group.enter()
                Task {
                    keyListener.listen(terminal: terminal) { keyStroke in
                        if state.shouldStop() {
                            return .abort
                        }

                        switch keyStroke {
                        case .upArrowKey, .printable("k"):
                            if let snap = state.moveSelection(delta: -1) {
                                render(snap)
                            }
                            return .continue
                        case .downArrowKey, .printable("j"):
                            if let snap = state.moveSelection(delta: 1) {
                                render(snap)
                            }
                            return .continue
                        case .pageUp:
                            if let snap = state.moveSelection(delta: -pageSize) {
                                render(snap)
                            }
                            return .continue
                        case .pageDown:
                            if let snap = state.moveSelection(delta: pageSize) {
                                render(snap)
                            }
                            return .continue
                        case .home:
                            if let snap = state.moveTo(index: 0) {
                                render(snap)
                            }
                            return .continue
                        case .end:
                            if let snap = state.moveToEnd() {
                                render(snap)
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
                    group.leave()
                }

                group.wait()
            }
        }

        return try state.result()
    }

    private func render(_ snapshot: LiveSelectableState.Snapshot) {
        let visibleRows = Array(snapshot.data.rows[snapshot.viewport.startIndex ..< snapshot.viewport.endIndex])
        let selectedInViewport = snapshot.selectedIndex - snapshot.viewport.startIndex

        let headers = snapshot.data.columns.map { $0.title.plain() }

        var widths = headers.map { $0.count }
        for row in visibleRows {
            for (idx, cell) in row.enumerated() {
                widths[idx] = max(widths[idx], cell.plain().count)
            }
        }

        func border(_ left: String, _ mid: String, _ right: String, fill: String) -> String {
            var parts: [String] = [left]
            for (idx, width) in widths.enumerated() {
                parts.append(String(repeating: fill, count: width + tableStyle.cellPadding * 2))
                if idx < widths.count - 1 { parts.append(mid) }
            }
            parts.append(right)
            return parts.joined().hexIfColored("505050", terminal: terminal)
        }

        func formatRow(_ cells: [TerminalText], selected: Bool) -> String {
            var parts: [String] = []
            let borderColor = "505050"

            parts.append("│".hexIfColored(borderColor, terminal: terminal))
            for (idx, cell) in cells.enumerated() {
                let width = widths[idx]
                let content = cell.plain()
                let truncated = content.count > width ? String(content.prefix(width - 1)) + "…" : content
                let padding = max(0, width - truncated.count)
                let padded = truncated + String(repeating: " ", count: padding)
                let pad = String(repeating: " ", count: tableStyle.cellPadding)
                var text = pad + padded + pad

                if selected {
                    text = text
                        .hexIfColored(tableStyle.selectionTextColor, terminal: terminal)
                        .onHexIfColored(tableStyle.selectionColor, terminal: terminal)
                } else {
                    text = TerminalText(stringLiteral: text).formatted(theme: theme, terminal: terminal)
                }

                parts.append(text)

                let borderPiece = "│".hexIfColored(borderColor, terminal: terminal)
                parts.append(selected ? borderPiece.onHexIfColored(tableStyle.selectionColor, terminal: terminal) : borderPiece)
            }

            return parts.joined()
        }

        var lines: [String] = []
        lines.append(border("╭", "┬", "╮", fill: "─"))
        lines.append(formatRow(headers.map { TerminalText(stringLiteral: $0) }, selected: false))
        if tableStyle.headerSeparator {
            lines.append(border("├", "┼", "┤", fill: "─"))
        }

        for (idx, row) in visibleRows.enumerated() {
            let selected = idx == selectedInViewport
            lines.append(formatRow(row, selected: selected))
        }

        lines.append(border("╰", "┴", "╯", fill: "─"))

        renderQueue.sync {
            renderer.render(lines.joined(separator: "\n"), standardPipeline: standardPipelines.output)
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
    private var data: TableData
    private var selectedIndex: Int
    private var viewport: TableViewport
    private var stopped = false
    private var selection: (name: String, signal: Int)?

    init(data: TableData, selectedIndex: Int, viewport: TableViewport) {
        self.data = data
        self.selectedIndex = selectedIndex
        self.viewport = viewport
    }

    func snapshot() -> Snapshot {
        queue.sync {
            Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func updateData(_ newData: TableData, pageSize: Int) -> Snapshot? {
        queue.sync {
            guard newData.isValid, !newData.rows.isEmpty else { return nil }
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
            return Snapshot(data: data, selectedIndex: selectedIndex, viewport: viewport)
        }
    }

    func selectCurrent() {
        queue.sync {
            stopped = true
            let row = data.rows[selectedIndex]
            let name = row.first?.plain() ?? ""
            let signalText = row.count > 1 ? row[1].plain().replacingOccurrences(of: " dBm", with: "") : "0"
            let signal = Int(signalText) ?? 0
            selection = (name, signal)
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

    func result() throws -> (name: String, signal: Int) {
        try queue.sync {
            guard let selection else {
                throw NooraError.userCancelled
            }
            return selection
        }
    }
}

private extension String {
    func hexIfColored(_ color: String, terminal: Terminaling) -> String {
        terminal.isColored ? hex(color) : self
    }

    func onHexIfColored(_ color: String, terminal: Terminaling) -> String {
        terminal.isColored ? onHex(color) : self
    }
}
