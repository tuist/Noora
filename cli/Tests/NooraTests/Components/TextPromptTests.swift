import Testing
@testable import Noora

struct TextPromptTests {
    let renderer = MockRenderer()
    let terminal = MockTerminal(isColored: false)
    let validator = MockValidator()

    @Test func renders_the_right_output() {
        // Given
        let subject = TextPrompt(
            title: "Project",
            prompt: "How would you like to name your project?",
            description: "The generated project will take this name",
            defaultValue: nil,
            theme: .test(),
            content: .default,
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil,
            validationRules: [],
            validator: validator
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
        #expect(validator.invokedValidateInputRulesCount == 1)
    }

    @Test func renders_the_right_output_when_no_title() {
        // Given
        let subject = TextPrompt(
            title: nil,
            prompt: "How would you like to name your project?",
            description: "The generated project will take this name",
            defaultValue: nil,
            theme: .test(),
            content: .default,
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil,
            validationRules: [],
            validator: validator
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
        #expect(validator.invokedValidateInputRulesCount == 1)
    }

    @Test func returns_default_value_when_input_is_empty() {
        // Given
        let subject = TextPrompt(
            title: "Name",
            prompt: "How would you like to name the project?",
            description: nil,
            defaultValue: "my-project",
            theme: .test(),
            content: .default,
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil,
            validationRules: [],
            validator: validator
        )
        terminal.characters = ["\n"]

        // When
        let result = subject.run()

        // Then
        #expect(result == "my-project")
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        Name
          How would you like to name the project? my-project█
        """)
        #expect(renders.popLast() == """
        Name
          How would you like to name the project? \("")
        """)
        #expect(renders.popLast() == """
        ✔︎ Name: my-project\(" ")
        """)
    }

    @Test func uses_typed_input_over_default_value() {
        // Given
        let subject = TextPrompt(
            title: "Name",
            prompt: "How would you like to name the project?",
            description: nil,
            defaultValue: "my-project",
            theme: .test(),
            content: .default,
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            logger: nil,
            validationRules: [],
            validator: validator
        )
        terminal.characters = ["F", "o", "o", "\n"]

        // When
        let result = subject.run()

        // Then
        #expect(result == "Foo")
    }
}
