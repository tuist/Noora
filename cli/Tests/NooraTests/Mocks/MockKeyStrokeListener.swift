import Noora

class MockKeyStrokeListener: KeyStrokeListening {
    var keyPressStub: [KeyStroke] = []

    func listen(terminal _: any Terminaling, onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        for keyStroke in keyPressStub {
            _ = onKeyPress(keyStroke)
        }
    }
}
