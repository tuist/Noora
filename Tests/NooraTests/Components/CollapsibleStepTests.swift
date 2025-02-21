import Testing
@testable import Noora

struct CollapsibleStepTests {
    let renderer = MockRenderer()

    @Test func run_whenInteractive() async throws {
        // Given
        let terminal = MockTerminal(isInteractive: true, isColored: false)
        let subject = CollapsibleStep(
            title: "Build",
            successMessage: "Build succeeded",
            errorMessage: "Build failed",
            visibleLines: 3,
            task: { log in
                for step in 1 ..< 5 {
                    log("Build step \(step)")
                }
            },
            theme: .test(),
            terminal: terminal,
            renderer: renderer,
            standardPipelines: StandardPipelines()
        )

        // When
        try await subject.run()

        // Then
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        ◉ Build
        """)
        #expect(renders.popLast() == """
        ◉ Build
          Build step 1
        """)
        #expect(renders.popLast() == """
        ◉ Build
          Build step 1
          Build step 2
        """)
        #expect(renders.popLast() == """
        ◉ Build
          Build step 1
          Build step 2
          Build step 3
        """)
        #expect(renders.popLast() == """
        ◉ Build
          Build step 2
          Build step 3
          Build step 4
        """)
        #expect(renders.popLast() == """
        ✔︎ Build succeeded 
        """)
    }

    @Test func run_whenNonInteractive() async throws {
        // Given
        let terminal = MockTerminal(isInteractive: false, isColored: false)
        let standardOutput = MockStandardPipeline()
        let standardError = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput, error: standardError)
        let subject = CollapsibleStep(
            title: "Build",
            successMessage: "Build succeeded",
            errorMessage: "Build failed",
            visibleLines: 3,
            task: { log in
                for step in 1 ..< 5 {
                    log("Build step \(step)")
                }
            },
            theme: .test(),
            terminal: terminal,
            renderer: renderer,
            standardPipelines: standardPipelines
        )

        // When
        try await subject.run()

        // Then
        #expect(standardOutput.writtenContent.trimmingCharacters(in: .whitespacesAndNewlines) == """
        ◉ Build 
          Build step 1
          Build step 2
          Build step 3
          Build step 4
          Build succeeded
        """.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
