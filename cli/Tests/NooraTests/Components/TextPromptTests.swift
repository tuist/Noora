import Testing
@testable import Noora

struct TextPromptTests {
    let renderer = MockRenderer()
    let terminal = MockTerminal(isColored: false)
    let keyStrokeListener = MockKeyStrokeListener()
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
            keyStrokeListener: keyStrokeListener,
            logger: nil,
            validationRules: [],
            validator: validator
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [
                .printable("M"),
                .printable("y"),
                .printable("A"),
                .printable("p"),
                .printable("p"),
                .backspace,
                .printable("p"),
                .returnKey,
            ]
        }

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
            keyStrokeListener: keyStrokeListener,
            logger: nil,
            validationRules: [],
            validator: validator
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [
                .printable("M"),
                .printable("y"),
                .printable("A"),
                .printable("p"),
                .printable("p"),
                .backspace,
                .printable("p"),
                .returnKey,
            ]
        }

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
            keyStrokeListener: keyStrokeListener,
            logger: nil,
            validationRules: [],
            validator: validator
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.returnKey]
        }

        // When
        let result = subject.run()

        // Then
        #expect(result == "my-project")
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        Name
          How would you like to name the project? █
          Press Enter to use my-project
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
            keyStrokeListener: keyStrokeListener,
            logger: nil,
            validationRules: [],
            validator: validator
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [.printable("F"), .printable("o"), .printable("o"), .returnKey]
        }

        // When
        let result = subject.run()

        // Then
        #expect(result == "Foo")
    }

    @Test func supports_cursor_movement() {
        // Given
        let subject = TextPrompt(
            title: "Name",
            prompt: "How would you like to name the project?",
            description: nil,
            defaultValue: nil,
            theme: .test(),
            content: .default,
            terminal: terminal,
            collapseOnAnswer: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            logger: nil,
            validationRules: [],
            validator: validator
        )
        keyStrokeListener.keyPressStub.withValue {
            $0 = [
                .printable("A"),
                .printable("C"),
                .leftArrowKey,
                .printable("B"),
                .rightArrowKey,
                .printable("D"),
                .returnKey,
            ]
        }

        // When
        let result = subject.run()

        // Then
        #expect(result == "ABCD")
        var renders = Array(renderer.renders.reversed())

        // Initial empty state
        #expect(renders.popLast() == "Name\n  How would you like to name the project? █")

        // After 'A'
        #expect(renders.popLast() == "Name\n  How would you like to name the project? A█")

        // After 'C'
        #expect(renders.popLast() == "Name\n  How would you like to name the project? AC█")

        // After Left Arrow (cursor is at 'C')
        #expect(renders.popLast() == "Name\n  How would you like to name the project? A█C")

        // After 'B' (inserted before 'C')
        #expect(renders.popLast() == "Name\n  How would you like to name the project? AB█C")

        // After Right Arrow (cursor is at end)
        #expect(renders.popLast() == "Name\n  How would you like to name the project? ABC█")

        // After 'D'
        #expect(renders.popLast() == "Name\n  How would you like to name the project? ABCD█")

        // Final states
        #expect(renders.popLast() == "Name\n  How would you like to name the project? ABCD")
        #expect(renders.popLast() == "✔︎ Name: ABCD ")
    }
}
