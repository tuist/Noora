import Logging
import Testing

@testable import Noora

struct TableTests {
    let renderer = MockRenderer()
    let terminal = MockTerminal(size: .init(rows: 20, columns: 80))
    let theme = Theme.test()
    let logger = Logger(label: "test")
    let keyStrokeListener = MockKeyStrokeListener()

    @Test func test_table_renders_correctly() throws {
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

        let subject = Table(
            data: data,
            style: style,
            terminal: terminal,
            theme: theme,
            logger: logger
        )

        // When
        let result = subject.render()

        // Then
        #expect(result.contains("╭────┬───────╮"))
        #expect(result.contains("│ ID │ Name  │"))
        #expect(result.contains("├────┼───────┤"))
        #expect(result.contains("│ 1  │ Alice │"))
        #expect(result.contains("│ 2  │ Bob   │"))
        #expect(result.contains("╰────┴───────╯"))
    }

    @Test func test_table_with_empty_rows() throws {
        // Given
        let columns = [
            TableColumn(title: TerminalText(stringLiteral: "Name"), width: .auto, alignment: .left),
            TableColumn(title: TerminalText(stringLiteral: "Age"), width: .auto, alignment: .left),
        ]
        let data = TableData(columns: columns, rows: [])
        let style = TableStyle(theme: .test())

        let subject = Table(
            data: data,
            style: style,
            terminal: terminal,
            theme: theme,
            logger: logger
        )

        // When
        let result = subject.render()

        // Then
        #expect(result.contains("Name"))
        #expect(result.contains("Age"))
        #expect(result.contains("╭"))
        #expect(result.contains("╰"))
    }

    @Test func test_interactive_table_error_handling() throws {
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
        let subject = InteractiveTable(
            data: data,
            style: style,
            pageSize: 5,
            renderer: renderer,
            terminal: nonInteractiveTerminal,
            theme: theme,
            keyStrokeListener: keyStrokeListener,
            logger: logger
        )

        // When/Then
        #expect(throws: NooraError.nonInteractiveTerminal.self) {
            try subject.run()
        }
    }

    @Test func test_table_output_structure() throws {
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

        let subject = Table(
            data: data,
            style: style,
            terminal: terminal,
            theme: theme,
            logger: logger
        )

        // When
        let result = subject.render()

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

        #expect(result == expectedOutput)
    }

    @Test func test_table_with_semantic_styles() throws {
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

        let subject = Table(
            data: data,
            style: style,
            terminal: terminal,
            theme: theme,
            logger: logger
        )

        // When
        let result = subject.render()

        // Then
        #expect(result.contains("Level"))
        #expect(result.contains("Message"))
        #expect(result.contains("INFO"))
        #expect(result.contains("ERROR"))
        #expect(result.contains("Application started"))
        #expect(result.contains("Connection failed"))
    }
}
