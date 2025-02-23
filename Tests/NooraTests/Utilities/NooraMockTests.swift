import Testing
@testable import Noora

struct NooraMockTests {
    let subject = NooraMock()

    @Test func prefixesLines_when_stderrMessages() {
        // When
        subject.error(.alert("Project not found", nextSteps: [
            "Make sure the project exists in the server",
        ]), logger: nil)

        // Then
        #expect(subject.description == """
        stderr: ▌ ✖ Error
        stderr: ▌ Project not found
        stderr: ▌
        stderr: ▌ Sorry this didn’t work. Here’s what to try next:
        stderr: ▌  ▸ Make sure the project exists in the server
        """)
    }

    @Test func doesntPrefixLines_when_stdOutMessages() {
        // When
        subject.success(.alert("Project set up successfully", nextSteps: [
            "Build your project using 'tuist xcodebuild'",
        ]), logger: nil)

        // Then
        #expect(subject.description == """
        ▌ ✔ Success
        ▌ Project set up successfully
        ▌
        ▌ Recommended next steps:
        ▌  ▸ Build your project using 'tuist xcodebuild'
        """)
    }
}
