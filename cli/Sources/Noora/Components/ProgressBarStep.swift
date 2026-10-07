import Foundation
import Logging
import Rainbow

public struct ProgressBarUpdate: Sendable, Equatable {
    public let progress: Double
    public let detail: String?

    public init(progress: Double, detail: String? = nil) {
        self.progress = progress
        self.detail = detail
    }
}

struct ProgressBarStep<V> {
    // MARK: - Attributes

    let message: String
    let successMessage: String?
    let errorMessage: String?
    let task: (@escaping (ProgressBarUpdate) -> Void) async throws -> V
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let spinner: Spinning
    let logger: Logger?

    private let complete = "█"
    private let incomplete = "▒"
    private let width = 30

    init(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        task: @escaping (@escaping (ProgressBarUpdate) -> Void) async throws -> V,
        theme: Theme,
        terminal: Terminaling,
        renderer: Rendering,
        standardPipelines: StandardPipelines,
        spinner: Spinning = Spinner(),
        logger: Logger?
    ) {
        self.message = message
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.task = task
        self.theme = theme
        self.terminal = terminal
        self.renderer = renderer
        self.standardPipelines = standardPipelines
        self.spinner = spinner
        self.logger = logger
    }

    func run() async throws -> V {
        if terminal.isInteractive {
            return try await runInteractive()
        } else {
            return try await runNonInteractive()
        }
    }

    func runInteractive() async throws -> V {
        let start = DispatchTime.now()

        defer {
            spinner.stop()
        }

        var spinnerIcon: String?
        var lastProgress = 0.0
        var lastDetail: String?

        spinner.spin { icon in
            spinnerIcon = icon
            render(progress: lastProgress, icon: spinnerIcon ?? "ℹ︎", detail: lastDetail)
        }

        do {
            let result = try await task { update in
                lastProgress = update.progress
                lastDetail = update.detail
            }
            renderer.render(
                .progressCompletionMessage(
                    (successMessage ?? message).hexIfColoredTerminal(theme.primary, terminal).boldIfColoredTerminal(terminal),
                    timeString: timeString(start: start),
                    theme: theme,
                    terminal: terminal
                ),
                standardPipeline: standardPipelines.output
            )
            logger?.debug("'\(message)' succeeded with '\(successMessage ?? message)'")
            return result
        } catch {
            renderer.render(
                .progressErrorMessage(
                    (errorMessage ?? message).hexIfColoredTerminal(theme.danger, terminal).boldIfColoredTerminal(terminal),
                    timeString: timeString(start: start),
                    theme: theme,
                    terminal: terminal
                ),
                standardPipeline: standardPipelines.error
            )
            logger?.error("'\(message)' failed with '\(errorMessage ?? message)'")
            throw error
        }
    }

    func runNonInteractive() async throws -> V {
        let start = DispatchTime.now()

        do {
            render(progress: 0, icon: "ℹ︎", detail: nil)

            // The updated progress is ignored in non-interactive environments
            let result = try await task { update in
                render(progress: update.progress, icon: "ℹ︎", detail: update.detail)
            }

            let message: String = .progressCompletionMessage(
                successMessage ?? message,
                timeString: timeString(start: start),
                theme: theme,
                terminal: terminal
            )
            standardPipelines.output.write(content: "\(message)\n")
            logger?.debug("'\(message)' succeeded with '\(successMessage ?? message)'")
            return result
        } catch {
            standardPipelines.error
                .write(
                    content: "    \("⨯".hexIfColoredTerminal(theme.danger, terminal)) \((errorMessage ?? message).hexIfColoredTerminal(theme.muted, terminal)) \(timeString(start: start))\n"
                )
            logger?.error("'\(message)' failed with '\(errorMessage ?? message)'")
            throw error
        }
    }

    private func timeString(start: DispatchTime) -> String {
        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        return "[\(String(format: "%.1f", elapsedTime))s]".hexIfColoredTerminal(theme.muted, terminal)
    }

    private func render(progress: Double, icon: String, detail: String?) {
        let width = 30
        let completed: Int
        if progress == 0.0 {
            completed = 0
        } else {
            completed = Int(floor(30.0 * max(min(progress, 1.0), 0.0)))
        }
        let completedBar = String(repeating: "█", count: completed)
        let incompleteBar = String(repeating: "▒", count: width - completed)
        let bar = completedBar + incompleteBar
        let detailSuffix: String
        if let detail, !detail.isEmpty {
            detailSuffix = " (\(detail))"
        } else {
            detailSuffix = ""
        }
        let output =
            "\(icon.hexIfColoredTerminal(theme.primary, terminal)) \(message) \(bar.hexIfColoredTerminal(theme.primary, terminal))   \(Int(floor(progress * 100)))%\(detailSuffix)"
        if terminal.isInteractive {
            renderer.render(
                output,
                standardPipeline: standardPipelines.output
            )
        } else {
            standardPipelines.output.write(
                content: output + "\n"
            )
        }
    }
}
