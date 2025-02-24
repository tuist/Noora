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

    func withMouseTracking(
        trackMotion _: Bool,
        _ body: () throws -> Void
    ) rethrows {
        try body()
    }

    var characters: [Character] = []
    func readCharacter() -> Character? {
        if !characters.isEmpty {
            characters.removeFirst()
        } else {
            nil
        }
    }

    func readCharacterNonBlocking() -> Character? {
        if !characters.isEmpty {
            characters.removeFirst()
        } else {
            nil
        }
    }

    func size() -> TerminalSize? {
        constantSize
    }
}
