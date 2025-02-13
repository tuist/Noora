import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public protocol Terminaling {
    var isInteractive: Bool { get }
    var isColored: Bool { get }
    func withoutCursor(_ body: () throws -> Void) rethrows
    func inRawMode(_ body: @escaping () throws -> Void) rethrows
    func readCharacter() -> String?
}

public struct Terminal: Terminaling {
    public let isInteractive: Bool
    public let isColored: Bool

    public init(isInteractive: Bool = Terminal.isInteractive(), isColored: Bool = Terminal.isColored()) {
        self.isInteractive = isInteractive
        self.isColored = isColored
        for signalType in [SIGINT, SIGTERM, SIGQUIT, SIGHUP] {
            signal(signalType) { _ in
                print("\u{1B}[?25h", terminator: "")
                fflush(stdout)
                exit(0)
            }
        }
    }

    /// Runs a block of code while **hiding the cursor**, restoring it after execution.
    /// - Parameter body: The closure to execute with the cursor hidden.
    public func withoutCursor(_ body: () throws -> Void) rethrows {
        hideCursor()
        defer { showCursor() } // Ensures cursor restoration, even if body throws an error
        try body()
    }

    /// Hides the cursor in the terminal.
    public func hideCursor() {
        print("\u{1B}[?25l", terminator: "")
        fflush(stdout) // Ensures the escape sequence is sent immediately
    }

    /// Restores the cursor in the terminal.
    public func showCursor() {
        print("\u{1B}[?25h", terminator: "")
        fflush(stdout)
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
        term.c_lflag &= ~tcflag_t(ECHO | ICANON)
        tcsetattr(STDIN_FILENO, TCSANOW, &term) // Apply changes immediately
    }

    private func disableRawMode() {
        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        term.c_lflag |= tcflag_t(ECHO | ICANON)
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
