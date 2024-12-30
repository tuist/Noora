import Foundation
import Rainbow

class ProgressStep {
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
    var spinner: Spinning

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
        ///  ℹ︎
        let start = DispatchTime.now()

        // swiftlint:disable:next identifier_name
        var _error: Error?

        do {
            standardPipelines.output.write(content: "\("ℹ︎".hexIfColoredTerminal(theme.primary, terminal)) \(message)\n")

            try await action { progressMessage in
                self.standardPipelines.output
                    .write(content: "     \(progressMessage.hexIfColoredTerminal(self.theme.muted, self.terminal))\n")
            }
        } catch {
            _error = error
        }

        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        let timeString = "[\(String(format: "%.1f", elapsedTime))s]".hexIfColoredTerminal(theme.muted, terminal)

        if _error != nil {
            standardPipelines.error
                .write(
                    content: "    \("⨯".hexIfColoredTerminal(theme.danger, terminal)) \((errorMessage ?? message).hexIfColoredTerminal(theme.muted, terminal)) \(timeString)\n"
                )
        } else {
            let message = ProgressStep
                .completionMessage(successMessage ?? message, timeString: timeString, theme: theme, terminal: terminal)
            standardPipelines.output.write(content: "   \(message)\n")
        }

        // swiftlint:disable:next identifier_name
        if let _error {
            throw _error
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
                self.render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            }
        }

        // swiftlint:disable:next identifier_name
        var _error: Error?
        do {
            render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            try await action { progressMessage in
                lastMessage = progressMessage
                self.render(message: lastMessage, icon: spinnerIcon ?? "ℹ︎")
            }
        } catch {
            _error = error
        }

        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        let timeString = "[\(String(format: "%.1f", elapsedTime))s]".hexIfColoredTerminal(theme.muted, terminal)

        if _error != nil {
            renderer.render(
                "\("⨯".hexIfColoredTerminal(theme.danger, terminal)) \(errorMessage ?? message) \(timeString)",
                standardPipeline: standardPipelines.error
            )
        } else {
            renderer.render(
                ProgressStep
                    .completionMessage(successMessage ?? message, timeString: timeString, theme: theme, terminal: terminal),
                standardPipeline: standardPipelines.output
            )
        }

        // swiftlint:disable:next identifier_name
        if let _error {
            throw _error
        }
    }

    // MARK: - Private

    static func completionMessage(_ message: String, timeString: String? = nil, theme: Theme, terminal: Terminaling) -> String {
        "\("✔︎".hexIfColoredTerminal(theme.success, terminal)) \(message)\(timeString != nil ? " \(timeString!)" : "")"
    }

    private func render(message: String, icon: String) {
        renderer.render(
            "\(icon.hexIfColoredTerminal(theme.primary, terminal)) \(message)",
            standardPipeline: standardPipelines.output
        )
    }
}
