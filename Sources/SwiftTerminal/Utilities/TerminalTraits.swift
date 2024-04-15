#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

public struct TerminalSize: CustomDebugStringConvertible {
    
    public private(set) var ws_row: UInt16 = 0
    public private(set) var ws_col: UInt16 = 0
    public private(set) var ws_xpixel: UInt16 = 0
    public private(set) var ws_ypixel: UInt16 = 0
    
    public var debugDescription: String {
        return "Terminal size: \(self.ws_col) columns and \(self.ws_row) Rows"
    }
    
    public static func current() -> TerminalSize? {
        var size = TerminalSize()
        #if os(macOS)
        if ioctl(1, TIOCGWINSZ, &size) == 0 {
            return size
        } else {
            return nil
        }
        #else
        if ioctl(1, TIOCGWINSZ as! UInt, &size) == 0 {
            return size
        } else {
            return nil
        }
        #endif
    }
}

/**
 The function returns true when the terminal is interactive and false otherwise.
 */
public func isTerminalInteractive() -> Bool {
    if let _ = ProcessInfo.processInfo.environment["NO_TTY"] {
        return false
    } else if isatty(STDIN_FILENO) != 0 {
        return true
    } else {
        return false
    }
}

/**
 Returns true if components should be colored.
 */
public func shouldColorTerminalComponents() -> Bool {
    if let _ = ProcessInfo.processInfo.environment["NO_COLOR"] {
        return false
    } else {
        return true
    }
}
