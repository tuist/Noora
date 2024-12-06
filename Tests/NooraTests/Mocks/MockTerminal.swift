import Noora

struct MockTerminal: Terminaling {
    var isInteractive: Bool = true
    var isColored: Bool = true

    func inRawMode(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    var readCharacterStub: String? = nil
    func readCharacter() -> String? {
        readCharacterStub
    }
}
