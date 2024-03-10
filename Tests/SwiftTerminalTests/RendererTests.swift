import XCTest
@testable import SwiftTerminal

final class RendererTests: XCTestCase {
    var subject: Renderer!
    var outputStream: MockStandardOutputStreaming!

    override func setUp() async throws {
        try await super.setUp()
        outputStream = MockStandardOutputStreaming()
        subject = Renderer()
    }

    override func tearDown() async throws {
        outputStream = nil
        subject = nil
        try await super.tearDown()
    }

    func test_render() async throws {
        // When
        try await subject.render("line1\nline2", stream: outputStream)
        try await subject.render("line3\nline4", stream: outputStream)

        // Then
        let written = outputStream.written
        XCTAssertEqual(written, [
            "line1",
            "line2",
            "\u{001B}[1A",
            "\u{001B}[1A",
            "\r",
            "line3",
            "line4",
        ])
    }
}
