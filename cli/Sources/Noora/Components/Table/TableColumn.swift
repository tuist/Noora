import Foundation

/// Defines a column in a table
public struct TableColumn: Sendable {
    /// The title displayed in the header
    public let title: TerminalText

    /// The width configuration for this column
    public let width: Width

    /// Text alignment within the column
    public let alignment: Alignment

    /// Width configuration options
    public enum Width: Equatable, Sendable {
        /// Fixed width in characters
        case fixed(Int)

        /// Flexible width with optional constraints
        case flexible(min: Int = 0, max: Int? = nil)

        /// Automatically size based on content
        case auto
    }

    /// Text alignment options
    public enum Alignment: Equatable, Sendable {
        case left
        case center
        case right
    }

    /// Creates a new table column
    /// - Parameters:
    ///   - title: The header text for this column
    ///   - width: Width configuration (defaults to auto)
    ///   - alignment: Text alignment (defaults to left)
    public init(
        title: TerminalText,
        width: Width = .auto,
        alignment: Alignment = .left
    ) {
        self.title = title
        self.width = width
        self.alignment = alignment
    }

    /// Convenience initializer for string titles
    public init(
        title: String,
        width: Width = .auto,
        alignment: Alignment = .left
    ) {
        self.init(
            title: TerminalText(stringLiteral: title),
            width: width,
            alignment: alignment
        )
    }
}
