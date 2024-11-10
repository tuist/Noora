import Noora

extension NooraTheme {
    /// Returns a Noora theme with the Tuist colors.
    /// - Returns: A theme instance.
    static func tuist() -> NooraTheme {
        NooraTheme(
            primary: "A378F2",
            secondary: "FF8EC6",
            muted: "505050",
            accent: "FFFC67",
            danger: "FF2929",
            success: "89F94F"
        )
    }
}
