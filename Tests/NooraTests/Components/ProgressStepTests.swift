import Testing

@testable import Noora

struct ProgressStepTests {
    enum TestError: Error, Equatable {
        case loadError
    }

    let renderer = MockRenderer()
    let terminal = MockTerminal()
    let spinner = MockSpinner()

    @Test func renders_the_right_output_when_spinner_and_success() async throws {
        // Given
        let standardPipelines = StandardPipelines()

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            action: { reportProgress in
                reportProgress("Loading project at path Project/")
            },
            theme: Theme.test(),
            terminal: terminal,
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

    @Test func renders_the_right_output_when_spinner_and_failure() async throws {
        // Given
        let standardPipelines = StandardPipelines()
        let error = TestError.loadError
        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: true,
            action: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: terminal,
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

    @Test func renders_the_right_output_when_no_spinner_and_success() async throws {
        // Given
        let standardPipelines = StandardPipelines()

        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: false,
            action: { reportProgress in
                reportProgress("Loading project at path Project/")
            },
            theme: Theme.test(),
            terminal: terminal,
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
        #expect(spinner.stoppedCalls == 1)
    }

    @Test func renders_the_right_output_when_no_spinner_and_failure() async throws {
        // Given
        let standardPipelines = StandardPipelines()
        let error = TestError.loadError
        let subject = ProgressStep(
            message: "Loading project graph",
            successMessage: "Project graph loaded",
            errorMessage: "Failed to load the project graph",
            showSpinner: false,
            action: { _ in
                throw error
            },
            theme: Theme.test(),
            terminal: terminal,
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
