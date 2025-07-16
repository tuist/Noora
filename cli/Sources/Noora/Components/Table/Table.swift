import Foundation
import Logging

/// A static table component that renders tabular data
struct Table {
    let data: TableData
    let style: TableStyle
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let terminal: any Terminaling
    let theme: Theme
    let logger: Logger?
    let tableRenderer: TableRenderer

    /// Renders the table and returns the formatted output
    func run() {
        let table = tableRenderer.render(
            data: data,
            style: style,
            theme: theme,
            terminal: terminal,
            logger: logger
        )

        renderer.render(table, standardPipeline: standardPipelines.output)
    }
}

/// Layout information for table rendering
struct TableLayout {
    let columnWidths: [Int]
}

/// Border positions for rendering
enum BorderPosition {
    case top, middle, bottom
}
