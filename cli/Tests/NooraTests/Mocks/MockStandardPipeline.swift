@testable import Noora

final class MockStandardPipeline: StandardPipelining, @unchecked Sendable {
    let writtenContent = LockIsolated("")

    func write(content: String) {
        writtenContent.withValue {
            $0.append(content)
        }
    }
}
