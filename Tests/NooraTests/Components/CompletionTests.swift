import Testing

@testable import Noora

struct CompletionTests {
    let terminal = MockTerminal()

    @Test func renders_the_right_output_for_warnings() throws {
        // Given
        let standardErrorPipeline = MockStandardPipeline()
        let standardOutputPipeline = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutputPipeline, error: standardErrorPipeline)
        let subject = Alert(item: .warning([
            (
                "Your token is about to expire",
                nextStep: "Run \(.command("tuist projects token create")) to generate a new token."
            ),
        ]), standardPipelines: standardPipelines, terminal: terminal, theme: .default, logger: nil)

        // When
        subject.run()

        // Then
        #expect(standardOutputPipeline.writtenContent.contains("""
        ! Warning 

          The following items may need attention: 
           ▸ Your token is about to expire
            ↳ Run 'tuist projects token create' to generate a new token.
        """.trimmingCharacters(in: .newlines)))
    }

    @Test func renders_the_right_output_for_errors() throws {
        // Given
        let standardErrorPipeline = MockStandardPipeline()
        let standardOutputPipeline = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutputPipeline, error: standardErrorPipeline)
        let subject = Alert(
            item: .error(
                "The project generation failed",
                nextSteps: [
                    "Make sure you are using the latest Tuist version",
                    "If the problem persists, report it in the community forum.",
                ]
            ),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: .default,
            logger: nil
        )

        // When
        subject.run()

        // Then
        #expect(standardErrorPipeline.writtenContent.contains("""
        ✖ Error 
          The project generation failed 

          Sorry this didn’t work. Here’s what to try next: 
           ▸ Make sure you are using the latest Tuist version
           ▸ If the problem persists, report it in the community forum.
        """.trimmingCharacters(in: .newlines)))
    }

    @Test func renders_the_right_output_for_success() throws {
        // Given
        let standardErrorPipeline = MockStandardPipeline()
        let standardOutputPipeline = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutputPipeline, error: standardErrorPipeline)
        let subject = Alert(
            item: .success(
                "The project has been created",
                nextSteps: [
                    "Cache your project targets as binaries with \(.command("tuist cache"))",
                    "Check out our docs to learn more about Tuist at https://docs.tuist.dev",
                ]
            ),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: .default,
            logger: nil
        )

        // When
        subject.run()

        // Then
        #expect(standardOutputPipeline.writtenContent.contains("""
        ✔ Success 
          The project has been created 

          Recommended next steps: 
           ▸ Cache your project targets as binaries with 'tuist cache'
           ▸ Check out our docs to learn more about Tuist at https://docs.tuist.dev
        """.trimmingCharacters(in: .newlines)))
    }
}
