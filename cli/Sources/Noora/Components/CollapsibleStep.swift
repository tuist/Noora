import Foundation
import Logging
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
    let logger: Logger?

    init(
        title: TerminalText,
        successMessage: TerminalText?,
        errorMessage: TerminalText?,
        visibleLines: UInt,
        task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void,
        theme: Theme,
        terminal: Terminaling,
        renderer: Rendering,
        standardPipelines: StandardPipelines,
        logger: Logger?
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
        self.logger = logger
    }

    func run() async throws {
        logger?.debug("Running asynchronous task: \(title)")
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
                logger?.trace("\(line)")
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
        var lines: [String] = []
        do {
            try await task { logs in
                for logLine in logs.formatted(theme: theme, terminal: terminal).split(separator: "\n") {
                    lines.append(String(logLine))
                    logger?.trace("\(logLine)")
                    if lines.count > visibleLines {
                        lines.removeFirst()
                    }
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
            .progressCompletionMessage(formattedSuccessMessage(color: theme.primary), theme: theme, terminal: terminal),
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
            .progressErrorMessage(formattedErrorMessage(color: theme.primary), theme: theme, terminal: terminal),
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

    private func renderInteractiveLines(lines: [String]) {
        var content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
            .boldIfColoredTerminal(terminal)
        for line in lines {
            content.append("\n  \(line)")
        }
        renderer.render(content, standardPipeline: standardPipelines.output)
    }
}
