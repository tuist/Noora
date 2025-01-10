import Foundation
import Rainbow


class CLIProgressBar {
    
    let message: String
    let successMessage: String?
    let errorMessage: String?
    let total: Int
    let action: (@escaping (String) -> Void) async throws -> Void
    let theme: Theme
    let terminal: Terminaling
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    var progressBar: ProgressBar
    
    init(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        total: Int,
        action: @escaping (@escaping (String) -> Void) async throws -> Void,
        theme: Theme,
        terminal: Terminaling,
        renderer: Rendering,
        standardPipelines: StandardPipelines,
        progressBar: ProgressBar = DefaultProgressBar()
    ) {
        self.message = message
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.total = total
        self.action = action
        self.theme = theme
        self.terminal = terminal
        self.renderer = renderer
        self.standardPipelines = standardPipelines
        self.progressBar = progressBar
    }
    
    func run() async throws {
        if terminal.isInteractive {
            try await runInteractive()
        } else {
            try await runNonInteractive()
        }
    }
    
    func runInteractive() async throws {

        var bar: String = ""
        var progressPercentage = 0
        var lastMessage = message

        progressBar.startProgress(total: total, interval: 0.05) { progressBarState, percentage in
            bar = progressBarState
            progressPercentage = percentage
            self.render(lastMessage, bar, progressPercentage)
        }

        var _error: Error?
        do {
            self.render(lastMessage, bar, progressPercentage)
            try await action { progressMessage in
                lastMessage = progressMessage
                self.render(lastMessage, bar, progressPercentage)
            }
        } catch {
            _error = error
        }


        if _error != nil {
            renderer.render(
                "\("⨯".hexIfColoredTerminal(theme.danger, terminal)) \(errorMessage ?? message)",
                standardPipeline: standardPipelines.error
            )
        } else {
            renderer.render(
                CLIProgressBar
                    .completionMessage(lastMessage, bar, progressPercentage, theme: theme, terminal: terminal),
                standardPipeline: standardPipelines.output
            )
        }

        if let _error {
            throw _error
        }
    }
    // TODO: Implement runNonInteractive logic
    func runNonInteractive() async throws {
        
    }
    
    static func completionMessage(_ message: String, _ bar: String, _ percentage: Int, theme: Theme, terminal: Terminaling) -> String {
        "\(message) \(bar.hexIfColoredTerminal(theme.success, terminal))   \(percentage)% | Completed"
    }
    
    private func render(_ message: String, _ bar: String, _ percentage: Int) {
        renderer.render(
            "\(message) \(bar.hexIfColoredTerminal(theme.primary, terminal))   \(percentage)% |",
            standardPipeline: standardPipelines.output
        )
    }
}
