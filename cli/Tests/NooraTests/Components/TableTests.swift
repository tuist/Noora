import Foundation
import Logging
import Testing

@testable import Noora

struct TableTests {
    let renderer = MockRenderer()
    let terminal = MockTerminal(size: .init(rows: 20, columns: 80))
    let theme = Theme.test()
    let logger = Logger(label: "test")
    let keyStrokeListener = MockKeyStrokeListener()

    @Test func table_renders_correctly() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let rows = [
            [TerminalText(stringLiteral: "1"), TerminalText(stringLiteral: "Alice")],
            [TerminalText(stringLiteral: "2"), TerminalText(stringLiteral: "Bob")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = Table(
            data: data,
            style: style,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        subject.run()

        let expectedOutput = """
        ╭────┬───────╮
        │ ID │ Name  │
        ├────┼───────┤
        │ 1  │ Alice │
        │ 2  │ Bob   │
        ╰────┴───────╯
        """

        // Then
        #expect(renderer.renders.joined(separator: "\r") == expectedOutput)
    }

    @Test func updating_table_rerenders_on_updates() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "SSID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Signal"), width: .auto, alignment: .right),
        ]

        let initialRows = [
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-40 dBm")],
        ]

        let updatedRows = [
            [TerminalText(stringLiteral: "Office"), TerminalText(stringLiteral: "-65 dBm")],
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-72 dBm")],
        ]

        let finalRows = [
            [TerminalText(stringLiteral: "Library"), TerminalText(stringLiteral: "-55 dBm")],
        ]

        let data = TableData(columns: columns, rows: initialRows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let updates = AsyncStream<TableData> { continuation in
            continuation.yield(TableData(columns: columns, rows: updatedRows))
            continuation.yield(TableData(columns: columns, rows: finalRows))
            continuation.finish()
        }

        let subject = UpdatingTable(
            initialData: data,
            updates: updates,
            style: style,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: MockTerminal(isInteractive: true, isColored: false, size: .init(rows: 20, columns: 80)),
            theme: theme,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        await subject.run()

        // Then
        #expect(renderer.renders.count == 3)
        #expect(renderer.renders.first?.contains("Home") == true)
        #expect(renderer.renders[1].contains("Office"))
        #expect(renderer.renders.last?.contains("Library") == true)
    }

    @Test func updating_selectable_table_updates_and_selects_row() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Signal"), width: .auto, alignment: .right),
        ]

        let initialData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-40 dBm")],
            [TerminalText(stringLiteral: "Office"), TerminalText(stringLiteral: "-65 dBm")],
        ])

        let updatedData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-40 dBm")],
            [TerminalText(stringLiteral: "Office"), TerminalText(stringLiteral: "-65 dBm")],
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-72 dBm")],
        ])

        let updates = AsyncStream<TableData> { continuation in
            Task {
                try await Task.sleep(for: .milliseconds(20))
                continuation.yield(updatedData)
                continuation.finish()
            }
        }

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        keyStrokeListener.keyPressStub.withValue { $0 = [.downArrowKey, .returnKey] }
        keyStrokeListener.delay.withValue { $0 = 0.2 }
        defer {
            keyStrokeListener.delay.withValue { $0 = 0 }
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = UpdatingSelectableTable(
            initialData: initialData,
            updates: updates,
            style: TableStyle(theme: .test()),
            pageSize: 5,
            selectionTracking: .index,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        let selectedIndex = try await subject.run()

        // Then
        #expect(selectedIndex == 1)
        #expect(renderer.renders.last?.contains("Cafe") == true)
    }

    @Test func updating_selectable_table_tracks_selection_on_reorder() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "SSID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Signal"), width: .auto, alignment: .right),
        ]

        let initialData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Alpha"), TerminalText(stringLiteral: "-40 dBm")],
            [TerminalText(stringLiteral: "Bravo"), TerminalText(stringLiteral: "-65 dBm")],
            [TerminalText(stringLiteral: "Charlie"), TerminalText(stringLiteral: "-72 dBm")],
        ])

        let updatedData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Bravo"), TerminalText(stringLiteral: "-60 dBm")],
            [TerminalText(stringLiteral: "Alpha"), TerminalText(stringLiteral: "-42 dBm")],
            [TerminalText(stringLiteral: "Charlie"), TerminalText(stringLiteral: "-70 dBm")],
        ])

        let updates = AsyncStream<TableData> { continuation in
            Task {
                try await Task.sleep(for: .milliseconds(300))
                continuation.yield(updatedData)
                continuation.finish()
            }
        }

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        keyStrokeListener.keyPressStub.withValue { $0 = [.downArrowKey, .returnKey] }
        keyStrokeListener.delay.withValue { $0 = 0.2 }
        defer {
            keyStrokeListener.delay.withValue { $0 = 0 }
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = UpdatingSelectableTable(
            initialData: initialData,
            updates: updates,
            style: TableStyle(theme: .test()),
            pageSize: 5,
            selectionTracking: .automatic,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        let selectedIndex = try await subject.run()

        // Then
        #expect(selectedIndex == 0)
    }

    @Test func updating_selectable_table_tracks_selection_with_row_ids() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "SSID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Signal"), width: .auto, alignment: .right),
        ]

        let rowIDs: [AnyHashable] = ["wifi-1", "wifi-2", "wifi-3"]

        let initialData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-40 dBm")],
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-60 dBm")],
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-70 dBm")],
        ], rowIDs: rowIDs)

        let updatedData = TableData(columns: columns, rows: [
            [TerminalText(stringLiteral: "Home"), TerminalText(stringLiteral: "-68 dBm")],
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-60 dBm")],
            [TerminalText(stringLiteral: "Cafe"), TerminalText(stringLiteral: "-41 dBm")],
        ], rowIDs: [rowIDs[2], rowIDs[1], rowIDs[0]])

        let updates = AsyncStream<TableData> { continuation in
            Task {
                try await Task.sleep(for: .milliseconds(100))
                continuation.yield(updatedData)
                continuation.finish()
            }
        }

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        keyStrokeListener.keyPressStub.withValue { $0 = [.returnKey] }
        keyStrokeListener.delay.withValue { $0 = 0.25 }
        defer {
            keyStrokeListener.delay.withValue { $0 = 0 }
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = UpdatingSelectableTable(
            initialData: initialData,
            updates: updates,
            style: TableStyle(theme: .test()),
            pageSize: 5,
            selectionTracking: .automatic,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        let selectedIndex = try await subject.run()

        // Then
        #expect(selectedIndex == 2)
    }

    @Test func interactive_table_error_handling() throws {
        // Given
        let nonInteractiveTerminal = MockTerminal(isInteractive: false)
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let rows = [
            [TerminalText(stringLiteral: "Alice")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = SelectableTable(
            data: data,
            style: style,
            pageSize: 5,
            renderer: renderer,
            terminal: nonInteractiveTerminal,
            standardPipelines: standardPipelines,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When/Then
        #expect(throws: NooraError.nonInteractiveTerminal.self) {
            try subject.run()
        }
    }

    @Test func table_respects_emoji_width() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "E"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let rows = [
            [TerminalText(stringLiteral: "😀"), TerminalText(stringLiteral: "Alpha")],
            [TerminalText(stringLiteral: "😃"), TerminalText(stringLiteral: "Beta")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = Table(
            data: data,
            style: style,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        subject.run()

        // Then
        let expectedOutput = """
        ╭────┬───────╮
        │ E  │ Name  │
        ├────┼───────┤
        │ 😀 │ Alpha │
        │ 😃 │ Beta  │
        ╰────┴───────╯
        """

        #expect(renderer.renders.joined(separator: "\r") == expectedOutput)
    }

    @Test func table_output_structure() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "Status"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Task"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Duration"), width: .auto, alignment: .right),
        ]
        let rows = [
            [TerminalText(stringLiteral: "✓"), TerminalText(stringLiteral: "Build"), TerminalText(stringLiteral: "2.3s")],
            [TerminalText(stringLiteral: "✓"), TerminalText(stringLiteral: "Test"), TerminalText(stringLiteral: "1.5s")],
            [TerminalText(stringLiteral: "✗"), TerminalText(stringLiteral: "Deploy"), TerminalText(stringLiteral: "0.0s")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = Table(
            data: data,
            style: style,
            renderer: renderer,
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: theme,
            logger: logger,
            tableRenderer: TableRenderer()
        )

        // When
        subject.run()

        // Then
        let expectedOutput = """
        ╭────────┬────────┬──────────╮
        │ Status │ Task   │ Duration │
        ├────────┼────────┼──────────┤
        │ ✓      │ Build  │     2.3s │
        │ ✓      │ Test   │     1.5s │
        │ ✗      │ Deploy │     0.0s │
        ╰────────┴────────┴──────────╯
        """

        #expect(renderer.renders.joined(separator: "\r") == expectedOutput)
    }

    @Test func table_with_semantic_styles() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "Level"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Message"), width: .auto, alignment: .left),
        ]
        let rows = [
            [TerminalText("\(.success("INFO"))"), TerminalText("\(.primary("Application started"))")],
            [TerminalText("\(.danger("ERROR"))"), TerminalText("\(.secondary("Connection failed"))")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())
        let tableRenderer = TableRenderer()

        // When
        let result = tableRenderer.render(
            data: data,
            style: style,
            theme: theme,
            terminal: terminal,
            logger: logger
        )

        // Then
        #expect(result.contains("Level"))
        #expect(result.contains("Message"))
        #expect(result.contains("INFO"))
        #expect(result.contains("ERROR"))
        #expect(result.contains("Application started"))
        #expect(result.contains("Connection failed"))
    }

    @Test func paginated_table_static_mode_renders_correctly() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let rows = [
            [TerminalText(stringLiteral: "1"), TerminalText(stringLiteral: "Alice")],
            [TerminalText(stringLiteral: "2"), TerminalText(stringLiteral: "Bob")],
            [TerminalText(stringLiteral: "3"), TerminalText(stringLiteral: "Carol")],
        ]
        let data = TableData(columns: columns, rows: rows)
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        // Make the listener return 'q' immediately to exit
        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: nil,
            loadPage: nil
        )

        // When
        try subject.run()

        // Then
        #expect(renderer.renders.first?.contains("Alice") == true)
        #expect(renderer.renders.first?.contains("Bob") == true)
        #expect(renderer.renders.first?.contains("Page 1 of 2") == true)
    }

    @Test func paginated_table_lazy_loading_calls_loadPage() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        var loadedPages: [Int] = []

        // Make the listener return 'q' immediately to exit
        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 3,
            loadPage: { page in
                loadedPages.append(page)
                return [
                    [TerminalText(stringLiteral: "\(page * 2 + 1)"), TerminalText(stringLiteral: "User \(page * 2 + 1)")],
                    [TerminalText(stringLiteral: "\(page * 2 + 2)"), TerminalText(stringLiteral: "User \(page * 2 + 2)")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then
        #expect(loadedPages == [0])
        #expect(renderer.renders.last?.contains("User 1") == true)
        #expect(renderer.renders.last?.contains("Page 1 of 3") == true)
    }

    @Test func paginated_table_lazy_loading_caches_pages() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        var loadedPages: [Int] = []

        // Navigate: right (to page 2), left (back to page 1), quit
        keyStrokeListener.keyPressStub.withValue { $0 = [.rightArrowKey, .leftArrowKey, .printable("q")] }
        keyStrokeListener.delay.withValue { $0 = 0.05 }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
            keyStrokeListener.delay.withValue { $0 = 0 }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 3,
            loadPage: { page in
                loadedPages.append(page)
                return [
                    [TerminalText(stringLiteral: "\(page * 2 + 1)"), TerminalText(stringLiteral: "User \(page * 2 + 1)")],
                    [TerminalText(stringLiteral: "\(page * 2 + 2)"), TerminalText(stringLiteral: "User \(page * 2 + 2)")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then - page 0 should be loaded once (initially), page 1 loaded once (on navigation right)
        // Going back to page 0 should NOT reload it (cached)
        #expect(loadedPages.contains(0))
        #expect(loadedPages.contains(1))
        #expect(loadedPages.filter { $0 == 0 }.count == 1)
    }

    @Test func paginated_table_lazy_loading_shows_loading_state() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 2,
            loadPage: { _ in
                // Simulate a slight delay
                try await Task.sleep(for: .milliseconds(10))
                return [
                    [TerminalText(stringLiteral: "1")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then - First render should show loading state
        #expect(renderer.renders.first?.contains("Loading") == true)
    }

    @Test func paginated_table_lazy_loading_handles_errors() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        struct TestError: Error, LocalizedError {
            var errorDescription: String? { "Test error occurred" }
        }

        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 2,
            loadPage: { _ in
                throw TestError()
            }
        )

        // When
        try await subject.run()

        // Then - Should show error state with retry option
        #expect(renderer.renders.last?.contains("Error") == true)
        #expect(renderer.renders.last?.contains("Retry") == true)
    }

    @Test func paginated_table_non_interactive_fallback_for_lazy() async throws {
        // Given
        let nonInteractiveTerminal = MockTerminal(isInteractive: false)
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        var loadedPages: [Int] = []

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: nonInteractiveTerminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 3,
            loadPage: { page in
                loadedPages.append(page)
                return [
                    [TerminalText(stringLiteral: "\(page * 2 + 1)"), TerminalText(stringLiteral: "User \(page * 2 + 1)")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then - In non-interactive mode, only first page should be loaded and displayed
        #expect(loadedPages == [0])
        #expect(renderer.renders.last?.contains("User 1") == true)
    }

    @Test func paginated_table_lazy_loading_respects_startPage() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        var loadedPages: [Int] = []

        // Make the listener return 'q' immediately to exit
        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 5,
            startPage: 2,
            loadPage: { page in
                loadedPages.append(page)
                return [
                    [TerminalText(stringLiteral: "\(page * 2 + 1)"), TerminalText(stringLiteral: "User \(page * 2 + 1)")],
                    [TerminalText(stringLiteral: "\(page * 2 + 2)"), TerminalText(stringLiteral: "User \(page * 2 + 2)")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then - Should start at page 2 (0-indexed), showing "Page 3 of 5"
        #expect(loadedPages == [2])
        #expect(renderer.renders.last?.contains("User 5") == true)
        #expect(renderer.renders.last?.contains("Page 3 of 5") == true)
    }

    @Test func paginated_table_lazy_loading_clamps_invalid_startPage() async throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "ID"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        var loadedPages: [Int] = []

        keyStrokeListener.keyPressStub.withValue { $0 = [.printable("q")] }
        defer {
            keyStrokeListener.keyPressStub.withValue { $0 = [] }
        }

        let subject = PaginatedTable(
            data: data,
            style: style,
            pageSize: 2,
            renderer: renderer,
            terminal: terminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            standardPipelines: standardPipelines,
            logger: logger,
            tableRenderer: TableRenderer(),
            totalPages: 3,
            startPage: 100, // Invalid - beyond total pages
            loadPage: { page in
                loadedPages.append(page)
                return [
                    [TerminalText(stringLiteral: "\(page + 1)")],
                ]
            }
        )

        // When
        try await subject.run()

        // Then - Should clamp to last page (page 2, 0-indexed)
        #expect(loadedPages == [2])
        #expect(renderer.renders.last?.contains("Page 3 of 3") == true)
    }
}
