import Foundation
import Mockable

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public protocol Terminaling {
    var isInteractive: Bool { get }
    var isColored: Bool { get }
    func inRawMode(_ body: @escaping () throws -> Void) rethrows
    func readCharacter() -> String?
}

public struct Terminal: Terminaling {
    public let isInteractive: Bool
    public let isColored: Bool

    public init(isInteractive: Bool = Terminal.isInteractive(), isColored: Bool = Terminal.isColored()) {
        self.isInteractive = isInteractive
        self.isColored = isColored
    }

    /// Enables raw mode for the terminal and restores the mode after the body is executed.
    /// - Parameter body: The body to execute with raw mode enabled.
    public func inRawMode(_ body: () throws -> Void) rethrows {
        enableRawMode()
        defer { disableRawMode() }
        try body()
    }

    private func enableRawMode() {
        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        term.c_lflag &= ~UInt(ECHO | ICANON) // Disable echo and canonical mode
        tcsetattr(STDIN_FILENO, TCSANOW, &term)
    }

    private func disableRawMode() {
        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        term.c_lflag |= UInt(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSANOW, &term)
    }

    public func readCharacter() -> String? {
        var buffer: [UInt8] = [0]
        let readBytes = read(STDIN_FILENO, &buffer, 1)
        guard readBytes > 0 else { return nil }
        return String(bytes: buffer, encoding: .utf8)
    }

    /// The function returns true when the terminal is interactive and false otherwise.
    public static func isInteractive() -> Bool {
        if ProcessInfo.processInfo.environment["NO_TTY"] != nil {
            return false
        } else if isatty(STDIN_FILENO) != 0 {
            return true
        } else {
            return false
        }
    }

    /// Returns true if components should be colored.
    public static func isColored() -> Bool {
        if ProcessInfo.processInfo.environment["NO_COLOR"] != nil {
            return false
        } else {
            return true
        }
    }
}
