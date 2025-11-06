import Noora

class MockTerminal: Terminaling {
    var isInteractive: Bool = true
    var isColored: Bool = true
    private var constantSize: TerminalSize? = nil

    init(
        isInteractive: Bool = true,
        isColored: Bool = true,
        size: TerminalSize? = nil
    ) {
        self.isInteractive = isInteractive
        self.isColored = isColored
        constantSize = size
    }

    func inRawMode(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    func withoutCursor(_ body: () throws -> Void) rethrows {
        try body()
    }

    var characters: [Character] = []

    func readRawCharacter() -> Int32? {
        if let character = readCharacter()?.unicodeScalars.first?.value {
            return Int32(bitPattern: character)
        }
        return nil
    }

    func readCharacter() -> Character? {
        characters.removeFirst()
    }

    func readRawCharacterNonBlocking() -> Int32? {
        nil
    }

    func readCharacterNonBlocking() -> Character? {
        nil
    }

    func size() -> TerminalSize? {
        constantSize
    }
}
