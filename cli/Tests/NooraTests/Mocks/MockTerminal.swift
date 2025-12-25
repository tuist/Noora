@testable import Noora

final class MockTerminal: Terminaling, @unchecked Sendable {
    let _isInteractive: LockIsolated<Bool>
    let _isColored: LockIsolated<Bool>
    private let constantSize: LockIsolated<TerminalSize?>

    var isInteractive: Bool {
        _isInteractive.value
    }

    var isColored: Bool {
        _isColored.value
    }

    init(
        isInteractive: Bool = true,
        isColored: Bool = true,
        size: TerminalSize? = nil
    ) {
        _isInteractive = LockIsolated(isInteractive)
        _isColored = LockIsolated(isColored)
        constantSize = LockIsolated(size)
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
        constantSize.value
    }
}
