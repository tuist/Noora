import Testing

@testable import Noora

struct TextPromptTests {
    let renderer = MockRenderer()
    let terminal = MockTerminal(isColored: false)

    @Test func test_renders_the_right_output() {
        // Given
        let subject = TextPrompt(
            title: "Project",
            prompt: "How would you like to name your project?",
            description: "The generated project will take this name",
            theme: .test(),
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil
        )
        terminal.characters = ["M", "y", "A", "p", "p", "\u{08}", "p", "\n"]

        // When
        let result = subject.run()

        // Then
        #expect(result == "MyApp")
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? █
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? M█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? My█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyA█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyAp█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyApp█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyAp█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyApp█
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        Project
          How would you like to name your project? MyApp
          The generated project will take this name
        """)
        #expect(renders.popLast() == """
        ✔︎ Project: MyApp 
        """)
    }

    @Test func test_renders_the_right_output_when_no_title() {
        // Given
        let subject = TextPrompt(
            title: nil,
            prompt: "How would you like to name your project?",
            description: "The generated project will take this name",
            theme: .test(),
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil
        )
        terminal.characters = ["M", "y", "A", "p", "p", "\u{08}", "p", "\n"]

        // When
        let result = subject.run()

        // Then
        #expect(result == "MyApp")
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast()?.trimmingCharacters(in: .whitespacesAndNewlines) == """
        How would you like to name your project? █
        The generated project will take this name
        """.trimmingCharacters(in: .whitespacesAndNewlines))
        #expect(renders.popLast() == """
        How would you like to name your project? M█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? My█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyA█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyAp█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyApp█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyAp█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyApp█
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        How would you like to name your project? MyApp
        The generated project will take this name
        """)
        #expect(renders.popLast() == """
        ✔︎ How would you like to name your project?: MyApp 
        """)
    }
}
