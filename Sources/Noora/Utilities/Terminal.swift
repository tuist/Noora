import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public struct Terminal: CustomDebugStringConvertible {
    // swiftlint:disable:next identifier_name
    private var ws_row: UInt16 = 0
    public var width: UInt16 { ws_col }
    // swiftlint:disable:next identifier_name
    private var ws_col: UInt16 = 0
    public var height: UInt16 { ws_row }
    // swiftlint:disable:next identifier_name
    private var ws_xpixel: UInt16 = 0
    // swiftlint:disable:next identifier_name
    private var ws_ypixel: UInt16 = 0
    public let isInteractive: Bool
    public let isColored: Bool

    init(isInteractive: Bool = Terminal.isInteractive(), isColored: Bool = Terminal.isColored()) {
        self.isInteractive = isInteractive
        self.isColored = isColored
    }

    public var debugDescription: String {
        "Terminal size: \(ws_col) columns and \(ws_row) Rows"
    }

    public static func current() -> Terminal? {
        var terminal = Terminal()
        #if os(macOS)
            if ioctl(STDOUT_FILENO, TIOCGWINSZ, &terminal) == 0 {
                return terminal
            } else {
                return nil
            }
        #else
            if ioctl(STDOUT_FILENO, TIOCGWINSZ, &terminal) == 0 {
                return terminal
            } else {
                return nil
            }
        #endif
    }

    /// Enables raw mode for the terminal and restores the mode after the body is executed.
    /// - Parameter body: The body to execute with raw mode enabled.
    func inRawMode(_ body: () throws -> Void) rethrows {
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

    func readCharacter() -> String? {
        var buffer: [UInt8] = [0]
        let readBytes = read(STDIN_FILENO, &buffer, 1)
        guard readBytes > 0 else { return nil }
        return String(bytes: buffer, encoding: .utf8)
    }

    /// The function returns true when the terminal is interactive and false otherwise.
    private static func isInteractive() -> Bool {
        if ProcessInfo.processInfo.environment["NO_TTY"] != nil {
            return false
        } else if isatty(STDIN_FILENO) != 0 {
            return true
        } else {
            return false
        }
    }

    /// Returns true if components should be colored.
    private static func isColored() -> Bool {
        if ProcessInfo.processInfo.environment["NO_COLOR"] != nil {
            return false
        } else {
            return true
        }
    }
}
