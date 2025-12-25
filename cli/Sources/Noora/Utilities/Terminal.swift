import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif canImport(Bionic)
    import Bionic
#elseif os(Windows)
    import ucrt
    import WinSDK
#else
    import Darwin
#endif

public protocol Terminaling: Sendable {
    var isInteractive: Bool { get }
    var isColored: Bool { get }
    func withoutCursor(_ body: () throws -> Void) rethrows
    func inRawMode(_ body: @escaping () throws -> Void) rethrows
    func readRawCharacter() -> Int32?
    func readCharacter() -> Character?
    func readRawCharacterNonBlocking() -> Int32?
    func readCharacterNonBlocking() -> Character?
    func size() -> TerminalSize?
}

public struct TerminalSize: Sendable {
    public let rows: Int
    public let columns: Int

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
}

#if os(Windows)
    // Windows-specific buffer for handling extended key sequences
    private class WindowsKeyBuffer {
        static let shared = WindowsKeyBuffer()
        var pendingChars: [Int32] = []

        private init() {}
    }
#endif

public struct Terminal: Terminaling {
    public let isInteractive: Bool
    public let isColored: Bool

    public init(isInteractive: Bool = Terminal.isInteractive(), isColored: Bool = Terminal.isColored()) {
        self.isInteractive = isInteractive
        self.isColored = isColored
        #if os(Windows)
            let signals: [Int32] = [SIGINT, SIGTERM]
        #else
            let signals: [Int32] = [SIGINT, SIGTERM, SIGQUIT, SIGHUP]
        #endif

        for signalType in signals {
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
        #if !os(Windows)
            var term = termios()
            tcgetattr(STDIN_FILENO, &term)
            term.c_lflag &= ~tcflag_t(ECHO | ICANON)
            tcsetattr(STDIN_FILENO, TCSANOW, &term) // Apply changes immediately
        #endif
    }

    private func disableRawMode() {
        #if !os(Windows)
            var term = termios()
            tcgetattr(STDIN_FILENO, &term)
            term.c_lflag |= tcflag_t(ECHO | ICANON)
            tcsetattr(STDIN_FILENO, TCSANOW, &term)
        #endif
    }

    public func readRawCharacter() -> Int32? {
        #if !os(Windows)
            var term = termios()
            tcgetattr(fileno(stdin), &term) // Get terminal attributes
            var original = term

            term.c_lflag &= ~tcflag_t(ECHO | ICANON) // Disable echo & canonical mode
            tcsetattr(fileno(stdin), TCSANOW, &term) // Apply changes

            let char = getchar() // Read single character

            tcsetattr(fileno(stdin), TCSANOW, &original) // Restore original settings

            return char
        #else
            let char = _getch()

            // Handle extended keys (arrow keys, function keys, etc.)
            // On Windows, these return 0 or 224 (0xE0) followed by a scan code
            if char == 0 || char == 224 {
                // Read the actual scan code
                let scanCode = _getch()
                return scanCode
            }

            return char
        #endif
    }

    public func readCharacter() -> Character? {
        let reader = UTF8Reader {
            guard let rawChar = readRawCharacter() else { return nil }
            return UInt8(truncatingIfNeeded: rawChar)
        }
        return reader.readCharacter()
    }

    /// Returns the size of the terminal if available.
    public func size() -> TerminalSize? {
        #if os(Windows)
            var csbi = CONSOLE_SCREEN_BUFFER_INFO()
            let handle = GetStdHandle(DWORD(STD_OUTPUT_HANDLE))
            if GetConsoleScreenBufferInfo(handle, &csbi) {
                let columns = Int(csbi.srWindow.Right - csbi.srWindow.Left + 1)
                let rows = Int(csbi.srWindow.Bottom - csbi.srWindow.Top + 1)
                guard rows > 0, columns > 0 else {
                    return nil
                }
                return TerminalSize(rows: rows, columns: columns)
            } else {
                return nil
            }
        #else
            var w = winsize()
            if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w) == 0 {
                let rows = Int(w.ws_row)
                let cols = Int(w.ws_col)
                guard rows > 0, cols > 0 else {
                    return nil
                }
                return TerminalSize(rows: rows, columns: cols)
            } else {
                return nil
            }
        #endif
    }

    public func readRawCharacterNonBlocking() -> Int32? {
        #if !os(Windows)
            var term = termios()
            tcgetattr(fileno(stdin), &term) // Get terminal attributes
            var original = term

            let flags = fcntl(fileno(stdin), F_GETFL)
            _ = fcntl(fileno(stdin), F_SETFL, flags | O_NONBLOCK) // Set non-blocking mode

            term.c_lflag &= ~tcflag_t(ECHO | ICANON) // Disable echo & canonical mode
            tcsetattr(fileno(stdin), TCSANOW, &term) // Apply changes

            let char = getchar() // Read single character

            _ = fcntl(fileno(stdin), F_SETFL, flags)
            tcsetattr(fileno(stdin), TCSANOW, &original) // Restore original settings

            return char != EOF ? char : nil
        #else
            // On Windows, use the buffer to handle pending characters
            let buffer = WindowsKeyBuffer.shared

            // If we have a pending character in the buffer, return it
            if !buffer.pendingChars.isEmpty {
                return buffer.pendingChars.removeFirst()
            }

            // Check if a key is available
            if _kbhit() == 0 {
                return nil
            }

            let char = _getch()

            // Handle extended keys (arrow keys, function keys, etc.)
            // On Windows, these return 0 or 224 (0xE0) followed by a scan code
            if char == 0 || char == 224 {
                // Check if the scan code is available
                if _kbhit() != 0 {
                    // Read the actual scan code and return it
                    return _getch()
                } else {
                    // Store the prefix and wait for the next call
                    buffer.pendingChars.append(char)
                    return nil
                }
            }

            return char
        #endif
    }

    /// Reads a single character from standard input without blocking.
    /// - Returns: A Character if one was immediately available, or nil if no character was ready to be read.
    ///
    /// This method temporarily configures the terminal in non-blocking mode, meaning it will return immediately
    /// even if no input is available.
    public func readCharacterNonBlocking() -> Character? {
        if let char = readRawCharacterNonBlocking(),
           let scalar = UnicodeScalar(UInt32(char))
        {
            return Character(scalar)
        }

        return nil
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
        } else if ProcessInfo.processInfo.environment["CLICOLOR_FORCE"] != nil {
            return true
        } else {
            let isPiped = isatty(fileno(stdout)) == 0
            return !isPiped
        }
    }
}

/// A reader that decodes UTF-8 encoded bytes into characters.
struct UTF8Reader {
    private let readByte: () -> UInt8?

    /// Creates a reader with the given byte source.
    /// - Parameter readByte: A closure that returns the next byte, or `nil` if no more bytes are available.
    init(readByte: @escaping () -> UInt8?) {
        self.readByte = readByte
    }

    func readCharacter() -> Character? {
        guard let firstByte = readByte() else { return nil }
        guard let length = sequenceLength(forFirstByte: firstByte) else { return nil }
        guard let bytes = bytes(forSequenceOfLength: length, startingWith: firstByte) else { return nil }
        return character(from: bytes)
    }

    private func sequenceLength(forFirstByte byte: UInt8) -> Int? {
        switch byte {
        case 0x00 ... 0x7F: 1 // ASCII
        case 0xC0 ... 0xDF: 2 // 2-byte sequence
        case 0xE0 ... 0xEF: 3 // 3-byte sequence
        case 0xF0 ... 0xF7: 4 // 4-byte sequence
        default: nil
        }
    }

    private func bytes(forSequenceOfLength length: Int, startingWith firstByte: UInt8) -> [UInt8]? {
        var result: [UInt8] = [firstByte]
        for _ in 1 ..< length {
            guard let byte = readByte() else { return nil }
            result.append(byte)
        }
        return result
    }

    private func character(from bytes: [UInt8]) -> Character? {
        String(bytes: bytes, encoding: .utf8).flatMap(\.first)
    }
}
