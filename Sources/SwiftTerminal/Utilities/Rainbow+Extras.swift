import Foundation
import Rainbow

extension String {
    var redIfColorEnabled: String {
        if shouldColorTerminalComponents() {
            return red
        } else {
            return self
        }
    }

    func hexColorIfEnabled(_ hex: String) -> String {
        if shouldColorTerminalComponents() {
            return self.hex(hex)
        } else {
            return self
        }
    }
}
