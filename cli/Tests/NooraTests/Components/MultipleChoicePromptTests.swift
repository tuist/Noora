import Logging
import Testing
@testable import Noora

struct MultipleChoicePromptTests {
    enum Option: String, CaseIterable, CustomStringConvertible, Equatable {
        case option1
        case option2
        case option3

        var description: String {
            rawValue
        }
    }

    let renderer = MockRenderer()
    let terminal = MockTerminal(size: .init(rows: 10, columns: 80))
    let keyStrokeListener = MockKeyStrokeListener()

    @Test func renders_the_right_content() {
        // Given
        let subject = MultipleChoicePrompt(
            title: "Migration",
            question: "Select targets for migration to Tuist.",
            description: "You can select up to 3 targets for migration.",
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.downArrowKey, .upArrowKey]
        }

        // When
        let _: [Option] = subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())

        #expect(renders.popLast() == """
        ◉ Migration
          Select targets for migration to Tuist.
          You can select up to 3 targets for migration.
          ❯ ○ option1
            ○ option2
            ○ option3
          ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Migration
          Select targets for migration to Tuist.
          You can select up to 3 targets for migration.
            ○ option1
          ❯ ○ option2
            ○ option3
          ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Migration
          Select targets for migration to Tuist.
          You can select up to 3 targets for migration.
          ❯ ○ option1
            ○ option2
            ○ option3
          ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
    }

    @Test func renders_the_right_content_when_no_title() {
        // Given
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: "You can select up to 3 targets for migration.",
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.downArrowKey, .upArrowKey]
        }

        // When
        let _: [Option] = subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        print("")
        #expect(renders.popLast() == """
        Select targets for migration to Tuist.
        You can select up to 3 targets for migration.
        ❯ ○ option1
          ○ option2
          ○ option3
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.popLast() == """
        Select targets for migration to Tuist.
        You can select up to 3 targets for migration.
          ○ option1
        ❯ ○ option2
          ○ option3
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.popLast() == """
        Select targets for migration to Tuist.
        You can select up to 3 targets for migration.
        ❯ ○ option1
          ○ option2
          ○ option3
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
    }

    @Test func renders_the_right_content_when_more_options_than_terminal_height() {
        // Given
        let terminal = MockTerminal(isColored: false, size: .init(rows: 10, columns: 80))
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: nil,
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = .init(repeating: .downArrowKey, count: 20)
        }

        // When
        _ = subject.run(options: (1 ... 20).map { "Option \($0)" })

        // Then
        #expect(renderer.renders[0] == """
        Select targets for migration to Tuist.
        ❯ ○ Option 1
          ○ Option 2
          ○ Option 3
          ○ Option 4
          ○ Option 5
          ○ Option 6
          ○ Option 7
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renderer.renders[10] == """
        Select targets for migration to Tuist.
          ○ Option 8
          ○ Option 9
          ○ Option 10
        ❯ ○ Option 11
          ○ Option 12
          ○ Option 13
          ○ Option 14
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
    }

    @Test func renders_the_right_content_when_filtered() {
        // Given
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: nil,
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.printable("/"), .printable("l"), .printable("o"), .escape]
        }

        // When
        _ = subject.run(options: [
            "Lorem",
            "ipsum",
            "dolor",
            "sit",
            "amet",
            "consectetur",
            "adipiscing",
            "elit",
        ])

        // Then
        var renders = renderer.renders
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ Lorem
          ○ ipsum
          ○ dolor
          ○ sit
          ○ amet
          ○ consectetur
          ○ adipiscing
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        Filter: 
        ❯ ○ Lorem
          ○ ipsum
          ○ dolor
          ○ sit
          ○ amet
          ○ consectetur
        ↑/↓ up/down • [space] select • esc clear filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        Filter: l
        ❯ ○ Lorem
          ○ dolor
          ○ elit
        ↑/↓ up/down • [space] select • esc clear filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        Filter: lo
        ❯ ○ Lorem
          ○ dolor
        ↑/↓ up/down • [space] select • esc clear filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ Lorem
          ○ ipsum
          ○ dolor
          ○ sit
          ○ amet
          ○ consectetur
          ○ adipiscing
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
    }

    @Test func select_deselect_confirm_flow() {
        // Given
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: nil,
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [
                .printable(" "),
                .downArrowKey,
                .printable(" "),
                .printable(" "),
                .downArrowKey,
                .printable(" "),
                .returnKey,
            ]
        }

        // When
        _ = subject.run(options: ["one", "two", "three"])

        // Then
        var renders = renderer.renders
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ one
          ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ◉ one
          ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
        ❯ ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
        ❯ ◉ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
        ❯ ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
          ○ two
        ❯ ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
          ○ two
        ❯ ◉ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        ✔︎ Select targets for migration to Tuist.: one three 
        """)
    }

    @Test func min_limit_error() {
        // Given
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: nil,
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .unlimited,
            minLimit: .limited(count: 1, errorMessage: "Select at least 1 item."),
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.returnKey]
        }

        // When
        _ = subject.run(options: ["one", "two"])

        // Then
        var renders = renderer.renders
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ one
          ○ two
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ one
          ○ two
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        Error:
        · Select at least 1 item.
        """)
    }

    @Test func max_limit_error() {
        // Given
        let subject = MultipleChoicePrompt(
            title: nil,
            question: "Select targets for migration to Tuist.",
            description: nil,
            theme: Theme.test(),
            content: .default,
            terminal: terminal,
            collapseOnSelection: true,
            filterMode: .toggleable,
            maxLimit: .limited(count: 2, errorMessage: "You can select only 2 items."),
            minLimit: .unlimited,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.printable(" "), .downArrowKey, .printable(" "), .downArrowKey, .printable(" ")]
        }

        // When
        _ = subject.run(options: ["one", "two", "three"])

        // Then
        var renders = renderer.renders
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ○ one
          ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
        ❯ ◉ one
          ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
        ❯ ○ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
        ❯ ◉ two
          ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
          ◉ two
        ❯ ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        """)
        #expect(renders.removeFirst() == """
        Select targets for migration to Tuist.
          ◉ one
          ◉ two
        ❯ ○ three
        ↑/↓/k/j up/down • [space] select • / filter • enter confirm
        Error:
        · You can select only 2 items.
        """)
    }
}
