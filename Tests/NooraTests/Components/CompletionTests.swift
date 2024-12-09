import Testing

@testable import Noora

struct CompletionTests {
    let terminal = MockTerminal()

    @Test func renders_the_right_content_when_only_one_item() throws {
        // Given
        let standardErrorPipeline = MockStandardPipeline()
        let standardOutputPipeline = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutputPipeline, error: standardErrorPipeline)
        let subject = Completion(
            item: .compound(Set([
                .warning(.string(
                    "Your token is about to expire",
                    next: "Run \(.command("tuist projects token create")) to generate a new token."
                )),
                .error(.string("The generation of the project failed.")),
            ])),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: .test()
        )

        // When
        subject.run()

        // Then
        #expect(standardOutputPipeline.writtenContent.contains("""
        [ Warning ]
        Your token is about to expire 

          Suggestion: 
            ▸ Run 'tuist projects token create' to generate a new token.

        """.trimmingCharacters(in: .newlines)))
        #expect(standardErrorPipeline.writtenContent.contains("""
        [ Error ]
        The generation of the project failed. 
        """.trimmingCharacters(in: .newlines)))
    }

    @Test func renders_the_right_content_when_multiple_items() throws {
        // Given
        let standardErrorPipeline = MockStandardPipeline()
        let standardOutputPipeline = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutputPipeline, error: standardErrorPipeline)
        let subject = Completion(
            item: .compound(Set([
                .warning(.list([
                    .string("The token is about to expire"),
                    .string("Config.swift has been renamed to Tuist.swift", next: "Rename the file to Tuist.swift"),
                ])),
            ])),
            standardPipelines: standardPipelines,
            terminal: terminal,
            theme: .test()
        )

        // When
        subject.run()

        // Then
        #expect(standardOutputPipeline.writtenContent.contains("""
        [ Warning ]
          ▸ 1. The token is about to expire 
          ▸ 2. Config.swift has been renamed to Tuist.swift 
             ↳ Rename the file to Tuist.swift 
        """.trimmingCharacters(in: .newlines)))
    }
}
