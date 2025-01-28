import Foundation
import Rainbow

struct ProgressStep {
    // MARK: - Attributes

    let message: String
    let successMessage: String?
    let errorMessage: String?
    let showSpinner: Bool
    let action: (@escaping (String) -> Void) async throws -> Void
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let spinner: Spinning

    init(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        action: @escaping (@escaping (String) -> Void) async throws -> Void,
        theme: Theme,
        terminal: Terminaling,
        renderer: Rendering,
        standardPipelines: StandardPipelines,
        spinner: Spinning = Spinner()
    ) {
        self.message = message
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.showSpinner = showSpinner
        self.action = action
        self.theme = theme
        self.terminal = terminal
        self.renderer = renderer
        self.standardPipelines = standardPipelines
        self.spinner = spinner
    }

    func run() async throws {
        if terminal.isInteractive {
            try await runInteractive()
        } else {
            try await runNonInteractive()
        }
    }

    func runNonInteractive() async throws {
        let start = DispatchTime.now()

        do {
            standardPipelines.output.write(content: "\("ℹ︎".hexIfColoredTerminal(theme.primary, terminal)) \(message)\n")

            try await action { progressMessage in
                standardPipelines.output
                    .write(content: "     \(progressMessage.hexIfColoredTerminal(theme.muted, terminal))\n")
            }

            let message = ProgressStep
                .completionMessage(
                    successMessage ?? message,
                    timeString: timeString(start: start),
                    theme: theme,
                    terminal: terminal
                )
            standardPipelines.output.write(content: "   \(message)\n")
        } catch {
            standardPipelines.error
                .write(
                    content: "    \("⨯".hexIfColoredTerminal(theme.danger, terminal)) \((errorMessage ?? message).hexIfColoredTerminal(theme.muted, terminal)) \(timeString(start: start))\n"
                )
            throw error
        }
    }

    func runInteractive() async throws {
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

        // swiftlint:disable:next identifier_name
        do {
            render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            try await action { progressMessage in
                lastMessage = progressMessage
                render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            }
            renderer.render(
                ProgressStep
                    .completionMessage(
                        successMessage ?? message,
                        timeString: timeString(start: start),
                        theme: theme,
                        terminal: terminal
                    ),
                standardPipeline: standardPipelines.output
            )
        } catch {
            renderer.render(
                "\("⨯".hexIfColoredTerminal(theme.danger, terminal)) \(errorMessage ?? message) \(timeString(start: start))",
                standardPipeline: standardPipelines.error
            )

            throw error
        }
    }

    static func completionMessage(_ message: String, timeString: String? = nil, theme: Theme, terminal: Terminaling) -> String {
        "\("✔︎".hexIfColoredTerminal(theme.success, terminal)) \(message)\(" \(timeString ?? "")")"
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
