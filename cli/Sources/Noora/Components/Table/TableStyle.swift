import Foundation

/// Defines the visual styling for a table
public struct TableStyle {
    /// Padding (spaces) on each side of cell content
    public let cellPadding: Int = 1

    /// Whether to show a separator line after headers
    public let headerSeparator: Bool = true

    /// Whether to highlight the entire row when selected
    public let highlightRow: Bool = true

    /// Characters for drawing borders
    public let borderCharacters: BorderCharacters = .rounded

    /// The selection background color (hex)
    public let selectionColor: String

    /// The selection text color (hex)
    public let selectionTextColor: String

    /// Creates the table style
    public init(
        theme: Theme
    ) {
        selectionColor = theme.selectedRowBackground
        selectionTextColor = theme.selectedRowText
    }
}

/// Characters used for drawing table borders
public struct BorderCharacters {
    public let horizontal: String
    public let vertical: String
    public let topLeft: String
    public let topRight: String
    public let bottomLeft: String
    public let bottomRight: String
    public let cross: String
    public let topJoin: String
    public let bottomJoin: String
    public let leftJoin: String
    public let rightJoin: String

    /// Rounded Unicode borders
    public static let rounded = BorderCharacters(
        horizontal: "─",
        vertical: "│",
        topLeft: "╭",
        topRight: "╮",
        bottomLeft: "╰",
        bottomRight: "╯",
        cross: "┼",
        topJoin: "┬",
        bottomJoin: "┴",
        leftJoin: "├",
        rightJoin: "┤"
    )
}
