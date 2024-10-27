import Foundation

public struct NooraEnvironment {
    var isInteractive: Bool
    var shouldColor: Bool

    public init(isInteractive: Bool, shouldColor: Bool) {
        self.isInteractive = isInteractive
        self.shouldColor = shouldColor
    }

    public static var `default`: NooraEnvironment {
        NooraEnvironment(isInteractive: isTerminalInteractive(), shouldColor: shouldColorTerminalComponents())
    }
}
