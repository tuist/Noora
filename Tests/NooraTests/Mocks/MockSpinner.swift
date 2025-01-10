@testable import Noora

class MockSpinner: Spinning {
    var lastBlock: ((String) -> Void)?
    func spin(_ block: @escaping (String) -> Void) {
        lastBlock = block
        block("⠋")
    }

    var stoppedCalls: UInt = 0
    func stop() {
        stoppedCalls += 1
    }
}
