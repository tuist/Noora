import Foundation
@testable import Noora

final class MockKeyStrokeListener: KeyStrokeListening {
    let keyPressStub = LockIsolated([KeyStroke]())
    let delay = LockIsolated<TimeInterval>(0)

    func listen(terminal _: any Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        for keyStroke in keyPressStub.value {
            if delay.value > 0 {
                Thread.sleep(forTimeInterval: delay.value)
            }
            _ = onKeyPress(keyStroke)
        }
    }
}
