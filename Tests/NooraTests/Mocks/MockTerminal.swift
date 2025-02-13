import Noora

class MockTerminal: Terminaling {
    var isInteractive: Bool = true
    var isColored: Bool = true

    init(
        isInteractive: Bool = true,
        isColored: Bool = true
    ) {
        self.isInteractive = isInteractive
        self.isColored = isColored
    }

    func inRawMode(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    func withoutCursor(_ body: () throws -> Void) rethrows {
        try body()
    }

    var characters: [Character] = []
    func readCharacter() -> Character? {
        characters.removeFirst()
    }
}
