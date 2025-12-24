import Foundation
import Logging

/// A table component that re-renders whenever its data changes
struct UpdatingTable<Updates: AsyncSequence> where Updates.Element == TableData {
    let initialData: TableData
    let updates: Updates
    let style: TableStyle
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let terminal: Terminaling
    let theme: Theme
    let logger: Logger?
    let tableRenderer: TableRenderer

    /// Renders the initial data and then re-renders on every update emitted by the sequence.
    func run() async {
        renderIfValid(initialData)

        do {
            for try await updatedData in updates {
                if Task.isCancelled {
                    break
                }

                renderIfValid(updatedData)
            }
        } catch {
            logger?.warning("Table updates stream failed: \(error)")
        }
    }

    private func renderIfValid(_ data: TableData) {
        guard data.isValid else {
            logger?.warning("Table data is invalid: row cell counts don't match column count")
            return
        }

        let table = tableRenderer.render(
            data: data,
            style: style,
            theme: theme,
            terminal: terminal,
            logger: logger
        )

        if terminal.isInteractive {
            terminal.withoutCursor {
                renderer.render(table, standardPipeline: standardPipelines.output)
            }
        } else {
            renderer.render(table, standardPipeline: standardPipelines.output)
        }
    }
}
