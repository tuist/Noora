import Foundation

public struct Theme {
    let primary: String
    let secondary: String
    let accent: String
    let danger: String
    let success: String

    public init(primary: String, secondary: String, accent: String, danger: String, success: String) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.danger = danger
        self.success = success
    }
}
