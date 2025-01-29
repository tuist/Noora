@testable import Noora

class MockSpinner: Spinning {
    func spin(_ block: @escaping (String) -> Void) {
        block("⠋")
    }

    var stoppedCalls: UInt = 0
    func stop() {
        stoppedCalls += 1
    }
}
