import Foundation
import Noora

class MockKeyStrokeListener: KeyStrokeListening {
    var keyPressStub: [KeyStroke] = []
    var delay: TimeInterval = 0

    func listen(terminal _: any Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        for keyStroke in keyPressStub {
            if delay > 0 {
                Thread.sleep(forTimeInterval: delay)
            }
            _ = onKeyPress(keyStroke)
        }
    }
}
