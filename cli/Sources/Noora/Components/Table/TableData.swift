import Foundation

/// Semantic styling options for table content
public enum TableCellStyle: Sendable {
    case plain(String)
    case primary(String)
    case secondary(String)
    case success(String)
    case warning(String)
    case danger(String)
    case muted(String)
    case accent(String)

    /// Convert to TerminalText
    func toTerminalText() -> TerminalText {
        switch self {
        case let .plain(text):
            return TerminalText(stringLiteral: text)
        case let .primary(text):
            return TerminalText("\(.primary(text))")
        case let .secondary(text):
            return TerminalText("\(.secondary(text))")
        case let .success(text):
            return TerminalText("\(.success(text))")
        case let .warning(text):
            return TerminalText("\(.danger(text))")
        case let .danger(text):
            return TerminalText("\(.danger(text))")
        case let .muted(text):
            return TerminalText("\(.muted(text))")
        case let .accent(text):
            return TerminalText("\(.accent(text))")
        }
    }
}

/// A stable identifier for a table row.
public struct TableRowID: Hashable, Sendable {
    private let box: TableRowIDBox

    public init(_ id: some Hashable & Sendable) {
        box = TableRowIDBox(id)
    }

    public func unwrap<ID: Hashable & Sendable>(_ type: ID.Type = ID.self) -> ID? {
        box.unbox(type)
    }

    public static func == (lhs: TableRowID, rhs: TableRowID) -> Bool {
        lhs.box == rhs.box
    }

    public func hash(into hasher: inout Hasher) {
        box.hash(into: &hasher)
    }
}

private struct TableRowIDBox: Hashable, Sendable {
    private let hash: @Sendable (inout Hasher) -> Void
    private let equals: @Sendable (TableRowIDBox) -> Bool
    private let unbox: @Sendable (Any.Type) -> Any?

    init<ID: Hashable & Sendable>(_ id: ID) {
        hash = { hasher in
            id.hash(into: &hasher)
        }
        unbox = { type in
            type == ID.self ? id : nil
        }
        equals = { other in
            guard let otherID = other.unbox(ID.self) as? ID else { return false }
            return id == otherID
        }
    }

    func unbox<ID: Hashable & Sendable>(_ type: ID.Type) -> ID? {
        unbox(type) as? ID
    }

    static func == (lhs: TableRowIDBox, rhs: TableRowIDBox) -> Bool {
        lhs.equals(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hash(&hasher)
    }
}

/// A row in a table, containing cells with TerminalText content and a stable identifier.
public struct TableRow: Identifiable, RandomAccessCollection, Sendable {
    public typealias Element = TerminalText
    public typealias Index = Int

    public let id: TableRowID
    public var cells: [TerminalText]

    public init(_ cells: [TerminalText], id: TableRowID? = nil) {
        self.cells = cells
        self.id = id ?? TableRow.defaultID(for: cells)
    }

    public init(_ styledCells: [TableCellStyle], id: TableRowID? = nil) {
        let resolved = styledCells.map { $0.toTerminalText() }
        cells = resolved
        self.id = id ?? TableRow.defaultID(for: resolved)
    }

    public init(_ cells: [TerminalText], id: some Hashable & Sendable) {
        self.cells = cells
        self.id = TableRowID(id)
    }

    public init(_ styledCells: [TableCellStyle], id: some Hashable & Sendable) {
        let resolved = styledCells.map { $0.toTerminalText() }
        cells = resolved
        self.id = TableRowID(id)
    }

    public var startIndex: Int { cells.startIndex }
    public var endIndex: Int { cells.endIndex }

    public subscript(position: Int) -> TerminalText {
        cells[position]
    }

    private static func defaultID(for cells: [TerminalText]) -> TableRowID {
        if let firstCell = cells.first {
            return TableRowID(firstCell.plain())
        }
        return TableRowID(cells.map { $0.plain() })
    }
}

/// A row in a table using semantic styling
public typealias StyledTableRow = [TableCellStyle]

/// Defines how to build a table cell from a data element.
public struct TerminalRow<Element> {
    let render: (Element) -> TerminalText

    public init(_ render: @escaping (Element) -> TerminalText) {
        self.render = render
    }

    public init(styled render: @escaping (Element) -> TableCellStyle) {
        self.render = { render($0).toTerminalText() }
    }
}

/// Represents the data structure for a table
public struct TableData: Sendable {
    /// Column definitions for the table
    public let columns: [TableColumn]

    /// Data rows for the table
    public let rows: [TableRow]

    /// Creates a new table data structure
    /// - Parameters:
    ///   - columns: Column definitions
    ///   - rows: Data rows (each row must have same count as columns)
    public init(columns: [TableColumn], rows: [TableRow]) {
        self.columns = columns
        self.rows = rows
    }

    /// Creates a new table data structure
    /// - Parameters:
    ///   - columns: Column definitions
    ///   - rows: Data rows (each row must have same count as columns)
    public init(columns: [TableColumn], rows: [[TerminalText]]) {
        self.columns = columns
        self.rows = rows.map { TableRow($0) }
    }

    /// Creates a new table data structure with styled content
    /// - Parameters:
    ///   - columns: Column definitions
    ///   - rows: Data rows using semantic styling
    public init(columns: [TableColumn], styledRows: [StyledTableRow]) {
        self.columns = columns
        rows = styledRows.map { TableRow($0) }
    }

    /// Creates a new table data structure from data with row builders.
    /// - Parameters:
    ///   - data: The data elements used to populate the rows.
    ///   - columns: Column definitions.
    ///   - rows: Row builders (one per column).
    public init<Data: RandomAccessCollection>(
        _ data: Data,
        columns: [TableColumn],
        rows: [TerminalRow<Data.Element>]
    ) where Data.Element: Identifiable, Data.Element.ID: Sendable {
        self.columns = columns
        self.rows = data.map { element in
            let cells = rows.map { $0.render(element) }
            return TableRow(cells, id: TableRowID(element.id))
        }
    }

    /// Creates a new table data structure from data with row builders.
    /// - Parameters:
    ///   - data: The data elements used to populate the rows.
    ///   - columns: Column definitions.
    ///   - rows: Row builders (one per column).
    public init<Data: RandomAccessCollection>(
        _ data: Data,
        columns: [TableColumn],
        rows: [TerminalRow<Data.Element>]
    ) {
        self.columns = columns
        self.rows = data.map { element in
            let cells = rows.map { $0.render(element) }
            return TableRow(cells)
        }
    }

    /// Validates that all rows have the correct number of cells
    public var isValid: Bool {
        rows.allSatisfy { $0.count == columns.count }
    }

    /// Returns a subset of rows for pagination
    /// - Parameters:
    ///   - page: Page number (0-indexed)
    ///   - pageSize: Number of rows per page
    /// - Returns: Subset of rows for the requested page
    public func page(at page: Int, size pageSize: Int) -> [TableRow] {
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, rows.count)

        guard startIndex < rows.count else { return [] }
        return Array(rows[startIndex ..< endIndex])
    }

    /// Total number of pages given a page size
    public func pageCount(size pageSize: Int) -> Int {
        guard pageSize > 0 else { return 1 }
        return (rows.count + pageSize - 1) / pageSize
    }
}

/// Represents a viewport into table rows for scrolling
public struct TableViewport: Sendable {
    /// First visible row index
    public var startIndex: Int

    /// Number of visible rows
    public let size: Int

    /// Total number of rows
    public let totalRows: Int

    /// Creates a new viewport
    public init(startIndex: Int = 0, size: Int, totalRows: Int) {
        self.startIndex = startIndex
        self.size = size
        self.totalRows = totalRows
    }

    /// Last visible row index
    public var endIndex: Int {
        min(startIndex + size, totalRows)
    }

    /// Adjusts viewport to ensure the given index is visible
    public mutating func scrollToShow(_ index: Int) {
        if index < startIndex {
            // Scroll up
            startIndex = index
        } else if index >= endIndex {
            // Scroll down
            startIndex = max(0, index - size + 1)
        }
    }

    /// Whether the viewport can scroll up
    public var canScrollUp: Bool {
        startIndex > 0
    }

    /// Whether the viewport can scroll down
    public var canScrollDown: Bool {
        endIndex < totalRows
    }
}
