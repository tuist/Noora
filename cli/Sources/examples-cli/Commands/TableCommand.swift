import ArgumentParser
import Dispatch
import Foundation
import Logging
import Noora
import Rainbow

struct TableCommand: AsyncParsableCommand {
    enum TableMode: String, CustomStringConvertible, ExpressibleByArgument, EnumerableFlag {
        case simple
        case styled
        case paginated
        case lazyPaginated
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
            case .lazyPaginated:
                return "Paginated table with lazy loading (simulates API pagination)"
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
        case .lazyPaginated:
            try await lazyPaginatedTable(noora)
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

    /// Demonstrates lazy loading paginated table that simulates fetching pages from an API
    private func lazyPaginatedTable(_ noora: Noora) async throws {
        let headers = ["ID", "User", "Email", "Department", "Status"]

        // Simulate a large dataset that would typically come from an API
        // Total: 100 users across 10 pages
        let totalPages = 10
        let pageSize = 10

        let departments = ["Engineering", "Marketing", "Sales", "Support", "HR", "Finance"]
        let statuses = ["Active", "Pending", "On Leave", "Inactive"]
        let firstNames = ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry", "Ivy", "Jack"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]

        noora.info(.alert(
            "Lazy Loading Paginated Table Demo",
            takeaways: [
                "This simulates fetching data from a paginated API",
                "Each page is loaded on-demand with a simulated network delay",
                "Pages are cached - navigating back won't re-fetch",
            ]
        ))

        try await noora.paginatedTable(
            headers: headers,
            pageSize: pageSize,
            totalPages: totalPages,
            loadPage: { page in
                // Simulate network delay (300-800ms)
                let delay = UInt64.random(in: 300_000_000 ... 800_000_000)
                try await Task.sleep(nanoseconds: delay)

                // Generate rows for this page
                var rows: [[String]] = []
                let startId = page * pageSize + 1

                for i in 0 ..< pageSize {
                    let userId = startId + i
                    let firstName = firstNames[userId % firstNames.count]
                    let lastName = lastNames[(userId * 3) % lastNames.count]
                    let email = "\(firstName.lowercased()).\(lastName.lowercased())@example.com"
                    let department = departments[userId % departments.count]
                    let status = statuses[userId % statuses.count]

                    rows.append([
                        "\(userId)",
                        "\(firstName) \(lastName)",
                        email,
                        department,
                        status,
                    ])
                }

                return rows
            }
        )
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

        await noora.table(initial, updates: updates)
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
        ) -> TableData {
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

            return TableData(columns: columns, rows: rows)
        }

        var rng = SystemRandomNumberGenerator()
        let initialData = snapshot(active: seedNetworks, rng: &rng)
        noora.info("Live Wi-Fi scan (updates). Use arrows/Enter to pick while it updates. Esc to cancel.")

        var latestData = initialData
        let snapshotQueue = DispatchQueue(label: "live-selectable-table-snapshot")

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
                       let newName = available.randomElement(using: &rng)
                    {
                        active.append(newName)
                    }

                    let tableData = snapshot(active: active, rng: &rng)
                    snapshotQueue.sync {
                        latestData = tableData
                    }
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

        let selectedIndex = try await noora.selectableTable(
            initialData,
            updates: updates,
            pageSize: 8
        )

        let finalData = snapshotQueue.sync { latestData }
        if finalData.rows.indices.contains(selectedIndex) {
            let row = finalData.rows[selectedIndex]
            let name = row.first?.plain() ?? "Unknown"
            let signal = row.dropFirst().first?.plain() ?? ""
            let suffix = signal.isEmpty ? "" : " (\(signal))"
            print("Selected network: \(name)\(suffix)")
        } else {
            print("Selected row: \(selectedIndex)")
        }
    }
}
