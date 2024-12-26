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
                standardPipeline: standardPipelines.output
            )
        } else {
            renderer.render(
                ProgressStep
                    .completionMessage(successMessage ?? message, timeString: timeString, theme: theme, terminal: terminal),
                standardPipeline: standardPipelines.output
            )
        }

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
