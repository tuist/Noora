import Testing

@testable import Noora

struct ProgressBarStepTests {
    enum TestError: Error, Equatable {
        case loadError
    }

    let renderer = MockRenderer()
    let spinner = MockSpinner()

    @Test func returns_task_value() async throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = ProgressBarStep(
            message: "Loading project graph",
            successMessage: nil,
            errorMessage: nil,
            task: { _ in
                "value"
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: nil
        )

        // When
        let value = try await subject.run()

        // Then
        #expect(value == "value")
    }

    @Test func renders_the_right_output_when_success_and_non_interactive_terminal() async throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = ProgressBarStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            task: { updateProgress in
                updateProgress(0.1)
                updateProgress(0.5)
                updateProgress(0.9)
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: false),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: nil
        )

        // When
        try await subject.run()

        // Then
        #expect(standardOutput.writtenContent.contains("""
        ℹ︎ Loading project graph
           ✔︎ Project graph loaded
        """) == true)
    }

    @Test func renders_the_right_output_when_failure_and_non_interactive_terminal() async throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)
        let error = TestError.loadError

        let subject = ProgressBarStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            task: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: false),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: nil
        )

        // When
        await #expect(throws: error, performing: subject.run)

        // Then
        print(standardError.writtenContent)
        #expect(standardOutput.writtenContent.contains("""
        ℹ︎ Loading project graph
        """) == true)
        #expect(standardError.writtenContent.contains("""
        ⨯ Failed to load the project graph
        """) == true)
    }

    @Test func renders_the_right_output_when_spinner_and_success_and_interactive_terminal() async throws {
        // Given
        let standardPipelines = StandardPipelines()

        let subject = ProgressBarStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            task: { updateProgress in
                updateProgress(0.1)
                spinner.lastBlock?("⠋")
                updateProgress(0.5)
                spinner.lastBlock?("⠋")
                updateProgress(0.9)
                spinner.lastBlock?("⠋")
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: nil
        )

        // When
        try await subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "⠋ Loading project graph ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   0%")
        #expect(renders.popLast() == "⠋ Loading project graph ███▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   10%")
        #expect(renders.popLast() == "⠋ Loading project graph ███████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   50%")
        #expect(renders.popLast() == "⠋ Loading project graph ███████████████████████████▒▒▒   90%")
        #expect(renders.popLast()?.range(of: "✔︎ Project graph loaded \\[.*s\\]", options: .regularExpression) != nil)
        #expect(spinner.stoppedCalls == 1)
    }

    @Test func renders_the_right_output_when_spinner_and_failure_and_interactive_terminal() async throws {
        // Given
        let standardPipelines = StandardPipelines()
        let error = TestError.loadError
        let subject = ProgressBarStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            task: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: nil
        )

        // When
        await #expect(throws: error, performing: subject.run)

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "⠋ Loading project graph ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   0%")
        #expect(renders.popLast()?.range(of: "⨯ Failed to load the project graph \\[.*s\\]", options: .regularExpression) != nil)
        #expect(spinner.stoppedCalls == 1)
    }
}
