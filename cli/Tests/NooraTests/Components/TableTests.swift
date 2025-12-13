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

        keyStrokeListener.keyPressStub = [.downArrowKey, .returnKey]
        keyStrokeListener.delay = 0.05
        defer {
            keyStrokeListener.delay = 0
            keyStrokeListener.keyPressStub = []
        }

        let subject = UpdatingSelectableTable(
            initialData: initialData,
            updates: updates,
            style: TableStyle(theme: .test()),
            pageSize: 5,
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
}
