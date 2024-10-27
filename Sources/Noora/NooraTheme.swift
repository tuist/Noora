import Foundation

/// This struct represents a them, which is used to visually configure components
/// ensuring that all components are consistent and aligned with a design identity.
public struct NooraTheme {
    /// A  primary color–it should represent the brand.
    let primary: String

    /// A secondary color–it should represent a secondary color of the brand.
    let secondary: String

    /// An accent color–it's used when sparingly to make a piece of content stand out.
    let accent: String

    /// A danger color–it's used sparingly to represent danger messages like errors.
    let danger: String

    /// A success color–it's used sparingly to represent a success messages like completion messages.
    let success: String

    /// Creates a new instance of the theme.
    /// - Parameters:
    ///   - primary: A  primary color–it should represent the brand.
    ///   - secondary: A secondary color–it should represent a secondary color of the brand.
    ///   - accent: An accent color–it's used when sparingly to make a piece of content stand out.
    ///   - danger: A danger color–it's used sparingly to represent danger messages like errors.
    ///   - success: A success color–it's used sparingly to represent a success messages like completion messages.
    public init(primary: String, secondary: String, accent: String, danger: String, success: String) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.danger = danger
        self.success = success
    }
}
