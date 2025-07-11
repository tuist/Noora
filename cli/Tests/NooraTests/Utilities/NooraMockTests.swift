import Testing
@testable import Noora

struct NooraMockTests {
    let subject = NooraMock()

    @Test func prefixesLines_when_stderrMessages() {
        // When
        subject.error(.alert("Project not found", takeaways: [
            "Make sure the project exists in the server",
        ]))

        // Then
        #expect(subject.description == """
        stderr: ✖ Error
        stderr:   Project not found
        stderr: 
        stderr:   Sorry this didn’t work. Here’s what to try next:
        stderr:    ▸ Make sure the project exists in the server
        """)
    }

    @Test func doesntPrefixLines_when_stdOutMessages() {
        // When
        subject.success(.alert("Project set up successfully", takeaways: [
            "Build your project using 'tuist xcodebuild'",
        ]))

        // Then
        #expect(subject.description == """
        ✔ Success
          Project set up successfully

          Takeaways:
           ▸ Build your project using 'tuist xcodebuild'
        """)
    }

    @Test func warningAlert_whenInterpolable_stdOutMessage() {
        // When
        let nooraVersion = 1.0
        subject.warning("Noora version outdated \(nooraVersion)")

        // Then
        #expect(subject.description == """
        ! Warning

          The following items may need attention:
           ▸ Noora version outdated 1.0
        """)
    }
}
