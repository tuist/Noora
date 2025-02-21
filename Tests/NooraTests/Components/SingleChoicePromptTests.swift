import Testing

@testable import Noora

struct SingleChoicePromptTests {
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

    @Test func renders_the_right_content() throws {
        // Given
        let subject = SingleChoicePrompt(
            title: "Integration",
            question: "How would you like to integrate Tuist?",
            description: "Decide how the integration should be with your project",
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener
        )
        keyStrokeListener.keyPressStub = [.downArrowKey, .upArrowKey]

        // When
        let _: Option = subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())

        #expect(renders.popLast() == """
        ◉ Integration
          How would you like to integrate Tuist?
          Decide how the integration should be with your project
            ❯ option1
              option2
              option3
          ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Integration
          How would you like to integrate Tuist?
          Decide how the integration should be with your project
              option1
            ❯ option2
              option3
          ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Integration
          How would you like to integrate Tuist?
          Decide how the integration should be with your project
            ❯ option1
              option2
              option3
          ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        ✔︎ Integration: option1 
        """)
    }

    @Test func renders_the_right_content_when_no_title() throws {
        // Given
        let subject = SingleChoicePrompt(
            title: nil,
            question: "How would you like to integrate Tuist?",
            description: "Decide how the integration should be with your project",
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener
        )
        keyStrokeListener.keyPressStub = [.downArrowKey, .upArrowKey]

        // When
        let _: Option = subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        How would you like to integrate Tuist?
        Decide how the integration should be with your project
          ❯ option1
            option2
            option3
        ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        How would you like to integrate Tuist?
        Decide how the integration should be with your project
            option1
          ❯ option2
            option3
        ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        How would you like to integrate Tuist?
        Decide how the integration should be with your project
          ❯ option1
            option2
            option3
        ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renders.popLast() == """
        ✔︎ How would you like to integrate Tuist?: option1 
        """)
    }

    @Test func renders_the_right_content_when_more_options_than_terminal_height() throws {
        // Given
        let subject = SingleChoicePrompt(
            title: nil,
            question: "How would you like to integrate Tuist?",
            description: nil,
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener
        )
        keyStrokeListener.keyPressStub = .init(repeating: .downArrowKey, count: 20)

        // When
        _ = subject.run(options: (1 ... 20).map { "Option \($0)" })

        // Then
        #expect(renderer.renders[0] == """
        How would you like to integrate Tuist?
          ❯ Option 1
            Option 2
            Option 3
            Option 4
            Option 5
            Option 6
            Option 7
        ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renderer.renders[10] == """
        How would you like to integrate Tuist?
            Option 8
            Option 9
            Option 10
          ❯ Option 11
            Option 12
            Option 13
            Option 14
        ↑/↓/k/j up/down • enter confirm
        """)
        #expect(renderer.renders[19] == """
        How would you like to integrate Tuist?
            Option 14
            Option 15
            Option 16
            Option 17
            Option 18
            Option 19
          ❯ Option 20
        ↑/↓/k/j up/down • enter confirm
        """)
    }
}
