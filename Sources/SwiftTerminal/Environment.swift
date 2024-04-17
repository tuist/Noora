import Foundation

public struct Environment {
    var isInteractive:  Bool
    var shouldColor: Bool
    
    public init(isInteractive: Bool, shouldColor: Bool) {
        self.isInteractive = isInteractive
        self.shouldColor = shouldColor
    }
    
    public static var `default`: Environment {
        Environment(isInteractive: isTerminalInteractive(), shouldColor: shouldColorTerminalComponents())
    }
}
