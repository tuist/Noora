import Foundation
import Logging
import Rainbow

struct ProgressStep<V> {
    // MARK: - Attributes

    let message: String
    let successMessage: String?
    let errorMessage: String?
    let showSpinner: Bool
    let task: (@escaping (String) -> Void) async throws -> V
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let spinner: Spinning
    let logger: Logger?

    init(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        task: @escaping (@escaping (String) -> Void) async throws -> V,
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
        self.showSpinner = showSpinner
        self.task = task
        self.theme = theme
        self.terminal = terminal
        self.renderer = renderer
        self.standardPipelines = standardPipelines
        self.spinner = spinner
        self.logger = logger
    }

    func run() async throws -> V {
        logger?.debug("Running asynchronous task: \(message)")
        if terminal.isInteractive {
            return try await runInteractive()
        } else {
            return try await runNonInteractive()
        }
    }

    func runNonInteractive() async throws -> V {
        let start = DispatchTime.now()

        do {
            standardPipelines.output.write(content: "\("ℹ︎".hexIfColoredTerminal(theme.primary, terminal)) \(message)\n")

            let result = try await task { progressMessage in
                standardPipelines.output
                    .write(content: "     \(progressMessage.hexIfColoredTerminal(theme.muted, terminal))\n")
            }

            let message: String = .progressCompletionMessage(
                successMessage ?? message,
                timeString: timeString(start: start),
                theme: theme,
                terminal: terminal
            )
            standardPipelines.output.write(content: "   \(message)\n")
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

    func runInteractive() async throws -> V {
        let start = DispatchTime.now()

        defer {
            if showSpinner {
                spinner.stop()
            }
        }

        var spinnerIcon: String?
        var lastMessage = message

        if showSpinner {
            spinner.spin { icon in
                spinnerIcon = icon
                render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            }
        }

        do {
            render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            let result = try await task { progressMessage in
                lastMessage = progressMessage
                render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
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

    private func render(message: String, icon: String) {
        renderer.render(
            "\(icon.hexIfColoredTerminal(theme.primary, terminal)) \(message)",
            standardPipeline: standardPipelines.output
        )
    }

    private func timeString(start: DispatchTime) -> String {
        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        return "[\(String(format: "%.1f", elapsedTime))s]".hexIfColoredTerminal(theme.muted, terminal)
    }
}

extension String {
    static func progressCompletionMessage(
        _ message: String,
        timeString: String? = nil,
        theme: Theme,
        terminal: Terminaling
    ) -> String {
        "\("✔︎".hexIfColoredTerminal(theme.success, terminal)) \(message)\(" \(timeString ?? "")")"
    }

    static func progressErrorMessage(
        _ message: String,
        timeString: String? = nil,
        theme: Theme,
        terminal: Terminaling
    ) -> String {
        "\("⨯".hexIfColoredTerminal(theme.danger, terminal)) \(message) \(timeString ?? "")"
    }
}
