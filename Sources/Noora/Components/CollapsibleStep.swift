import Foundation
import Rainbow

struct CollapsibleStep {
    // MARK: - Attributes

    let title: TerminalText
    let successMessage: TerminalText?
    let visibleLines: UInt
    let errorMessage: TerminalText?
    let task: (@escaping (TerminalText) -> Void) async throws -> Void
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let standardPipelines: StandardPipelines

    init(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void,
        theme: Theme,
        terminal: Terminaling,
        renderer: Rendering,
        standardPipelines: StandardPipelines
    ) {
        self.title = title
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.visibleLines = visibleLines
        self.task = task
        self.theme = theme
        self.terminal = terminal
        self.renderer = renderer
        self.standardPipelines = standardPipelines
    }

    func run() async throws {
        if terminal.isInteractive {
            try await runInteractive()
        } else {
            try await runNonInteractive()
        }
    }

    func runNonInteractive() async throws {
        standardPipelines.output
            .write(
                content: "◉ \(title.formatted(theme: theme, terminal: terminal))\n"
                    .hexIfColoredTerminal(theme.primary, terminal)
                    .boldIfColoredTerminal(terminal)
            )
        do {
            try await task { line in
                standardPipelines.output.write(content: "  \(line.formatted(theme: theme, terminal: terminal))\n")
            }
            standardPipelines.output.write(content: "  \(formattedSuccessMessage(color: theme.secondary))\n")
        } catch {
            standardPipelines.output.write(content: "  \(formattedErrorMessage(color: theme.secondary))\n")
            throw error
        }
    }

    func runInteractive() async throws {
        renderInteractiveLines(lines: [])
        var lines: [TerminalText] = []
        do {
            try await task { line in
                lines.append(line)
                if lines.count > visibleLines {
                    lines.removeFirst()
                }
                renderInteractiveLines(lines: lines)
            }
        } catch {
            renderInteractiveError()
            throw error
        }
        renderInteractiveSuccess()
    }

    private func renderInteractiveSuccess() {
        renderer.render(
            ProgressStep.completionMessage(formattedSuccessMessage(color: theme.primary), theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }

    private func formattedSuccessMessage(color: String) -> String {
        if let successMessage {
            "\(successMessage.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(color, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(color, terminal)
                .boldIfColoredTerminal(terminal)
        }
    }

    private func renderInteractiveError() {
        renderer.render(
            ProgressStep.errorMessage(formattedErrorMessage(color: theme.primary), theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.error
        )
    }

    private func formattedErrorMessage(color: String) -> String {
        if let errorMessage {
            "\(errorMessage.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(color, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(color, terminal)
                .boldIfColoredTerminal(terminal)
        }
    }

    private func renderInteractiveLines(lines: [TerminalText]) {
        var content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
            .boldIfColoredTerminal(terminal)
        for (index, line) in lines.enumerated() {
            content.append("\n  \(line.formatted(theme: theme, terminal: terminal))")
        }
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
