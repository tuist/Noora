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
    func readCharacter() -> Character?
    func size() -> TerminalSize?
}

public struct TerminalSize {
    let rows: Int
    let columns: Int
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

    public func readCharacter() -> Character? {
        var term = termios()
        tcgetattr(fileno(stdin), &term) // Get terminal attributes
        var original = term

        term.c_lflag &= ~tcflag_t(ECHO | ICANON) // Disable echo & canonical mode
        tcsetattr(fileno(stdin), TCSANOW, &term) // Apply changes

        let char = getchar() // Read single character

        tcsetattr(fileno(stdin), TCSANOW, &original) // Restore original settings
        return char != EOF ? Character(UnicodeScalar(UInt8(char))) : nil
    }

    /// Returns the size of the terminal if available.
    public func size() -> TerminalSize? {
        var w = winsize()
        if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w) == 0 {
            return TerminalSize(rows: Int(w.ws_row), columns: Int(w.ws_col))
        } else {
            return nil
        }
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
