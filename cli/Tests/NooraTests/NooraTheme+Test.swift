import Noora

extension Theme {
    /// Returns a Noora theme with the Tuist colors.
    /// - Returns: A theme instance.
    static func test() -> Theme {
        Theme(
            primary: "A378F2",
            secondary: "FF8EC6",
            muted: "505050",
            accent: "FFFC67",
            danger: "FF2929",
            success: "89F94F",
            info: "0280B9"
        )
    }
}
