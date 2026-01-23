import Foundation

/// Defines how selection behaves when updating tables reorder rows.
public enum TableSelectionTracking {
    /// Keeps the selection anchored to the current index when rows reorder.
    case index
    /// Tracks selection by a stable key derived from the selected row.
    case rowKey(@Sendable (TableRow) -> AnyHashable)
    /// Automatically tracks rows using row IDs when provided, falling back to the first column's text.
    case automatic

    /// Default tracking strategy for updating selectable tables.
    public static var defaultRowKey: TableSelectionTracking {
        .automatic
    }
}
