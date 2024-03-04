import MockableTest
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
        verify(outputStream)
            .write(content: .value("line1")).called(count: 1)
            .write(content: .value("line2")).called(count: 1)
            .write(content: .value("\u{001B}[1A")).called(count: 2)
            .write(content: .value("\r")).called(count: 1)
            .write(content: .value("line3")).called(count: 1)
            .write(content: .value("line4")).called(count: 1)
    }
}
