@testable import Noora

final class MockKeyStrokeListener: KeyStrokeListening, @unchecked Sendable {
    let keyPressStub = LockIsolated([KeyStroke]())

    func listen(terminal _: any Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        for keyStroke in keyPressStub.value {
            _ = onKeyPress(keyStroke)
        }
    }
}
