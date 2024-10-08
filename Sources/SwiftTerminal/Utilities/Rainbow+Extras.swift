import Foundation
import Rainbow

extension String {
    func redIfColorEnabled(environment: Environment = .default) -> String {
        if environment.shouldColor {
            return red
        } else {
            return self
        }
    }

    func dimIfColorEnabled(environment: Environment = .default) -> String {
        if environment.shouldColor {
            return dim
        } else {
            return self
        }
    }

    func hexColorIfEnabled(_ hex: String, environment: Environment = .default) -> String {
        if environment.shouldColor {
            return self.hex(hex)
        } else {
            return self
        }
    }
}
