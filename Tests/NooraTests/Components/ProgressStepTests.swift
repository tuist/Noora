import Testing

@testable import Noora

struct ProgressStepTests {
    enum TestError: Error, Equatable {
        case loadError
    }

    let logger = MockLogger()
    let renderer = MockRenderer()
    let spinner = MockSpinner()

    @Test func renders_the_right_output_when_success_and_non_interactive_terminal() async throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            task: { reportProgress in
                reportProgress("Loading project at path Project/")
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: false),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner,
            logger: logger
        )

        // When
        try await subject.run()

        // Then
        #expect(standardOutput.writtenContent.contains("""
        ℹ︎ Loading project graph
             Loading project at path Project/
           ✔︎ Project graph loaded
        """) == true)
    }

    @Test func renders_the_right_output_when_failure_and_non_interactive_terminal() async throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)
        let error = TestError.loadError

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            logger: logger,
            task: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: false),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner
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

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            logger: logger,
            task: { reportProgress in
                reportProgress("Loading project at path Project/")
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner
        )

        // When
        try await subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "⠋ Loading project graph")
        #expect(renders.popLast() == "⠋ Loading project graph")
        #expect(renders.popLast() == "⠋ Loading project at path Project/")
        #expect(renders.popLast()?.range(of: "✔︎ Project graph loaded \\[.*s\\]", options: .regularExpression) != nil)
        #expect(spinner.stoppedCalls == 1)
    }

    @Test func renders_the_right_output_when_spinner_and_failure_and_interactive_terminal() async throws {
        // Given
        let standardPipelines = StandardPipelines()
        let error = TestError.loadError
        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            logger: logger,
            task: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner
        )

        // When
        await #expect(throws: error, performing: subject.run)

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "⠋ Loading project graph")
        #expect(renders.popLast() == "⠋ Loading project graph")
        #expect(renders.popLast()?.range(of: "⨯ Failed to load the project graph \\[.*s\\]", options: .regularExpression) != nil)
        #expect(spinner.stoppedCalls == 1)
    }

    @Test func renders_the_right_output_when_no_spinner_and_success_and_interactive_terminal() async throws {
        // Given
        let standardPipelines = StandardPipelines()

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: false,
            logger: logger,
            task: { reportProgress in
                reportProgress("Loading project at path Project/")
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner
        )

        // When
        try await subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "ℹ︎ Loading project graph")
        #expect(renders.popLast() == "ℹ︎ Loading project at path Project/")
        #expect(renders.popLast()?.range(of: "✔︎ Project graph loaded \\[.*s\\]", options: .regularExpression) != nil)
    }

    @Test func renders_the_right_output_when_no_spinner_and_failure_and_interactive_terminal() async throws {
        // Given
        let standardPipelines = StandardPipelines()
        let error = TestError.loadError
        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: false,
            logger: logger,
            task: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: MockTerminal(isInteractive: true),
            renderer: renderer,
            standardPipelines: standardPipelines,
            spinner: spinner
        )

        // When
        await #expect(throws: error, performing: subject.run)

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == "ℹ︎ Loading project graph")
        #expect(renders.popLast()?.range(of: "⨯ Failed to load the project graph \\[.*s\\]", options: .regularExpression) != nil)
    }
}
