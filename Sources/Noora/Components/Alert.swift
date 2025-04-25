import Foundation
import Logging
import Rainbow

enum AlertItem {
    case warning([(TerminalText, nextStep: TerminalText?)])
    case success(TerminalText, nextSteps: [TerminalText] = [])
    case error(TerminalText, nextSteps: [TerminalText] = [])

    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
}

struct Alert {
    let item: AlertItem
    let standardPipelines: StandardPipelines
    let terminal: Terminaling
    let theme: Theme
    let logger: Logger?

    func run() {
        let standardPipeline = switch item {
        case .error: standardPipelines.error
        default: standardPipelines.output
        }

        let (title, color, recommendedTitle) = switch item {
        case .error: ("✖ Error ", theme.danger, "Sorry this didn’t work. Here’s what to try next")
        case .warning: ("! Warning ", theme.accent, "The following items may need attention")
        case .success: ("✔ Success ", theme.success, "Recommended next steps")
        }

        standardPipeline.write(content: "\(title)\n".boldIfColoredTerminal(terminal).hexIfColoredTerminal(color, terminal))

        switch item {
        case let .error(message, nextSteps), let .success(message, nextSteps: nextSteps):
            for messageLine in message.formatted(theme: theme, terminal: terminal).split(separator: "\n") {
                standardPipeline.write(content: "  \(messageLine) \n")
            }
            var logMessage = """
            \(item.isSuccess ? "Success" : "Error") alert: \(title)
              - Message: \(message)
            """
            if !nextSteps.isEmpty {
                standardPipeline.write(content: "\n  \(recommendedTitle.boldIfColoredTerminal(terminal)): \n")
                logMessage = """
                \(logMessage)
                  - Next steps:
                \(nextSteps.map { "    - \($0)" }.joined(separator: "\n"))
                """
                for nextItem in nextSteps {
                    for (nextItemIndex, nextItemLine) in nextItem.formatted(theme: theme, terminal: terminal)
                        .split(separator: "\n").enumerated()
                    {
                        if nextItemIndex == 0 {
                            standardPipeline.write(content: "   ▸ \(nextItemLine)\n")
                        } else {
                            standardPipeline.write(content: "     \(nextItemLine)\n")
                        }
                    }
                }
            }
            logger?.debug("\(logMessage)")
        case let .warning(messages):
            standardPipeline.write(content: "\n  \(recommendedTitle.boldIfColoredTerminal(terminal)): \n")
            logger?.debug("""
            Warning alert: \(title)
              - Messages:
            \(messages.map { "    - \($0)" }.joined(separator: "\n"))
            """)

            for (message, next) in messages {
                standardPipeline.write(content: "   ▸ \(message.formatted(theme: theme, terminal: terminal))\n")
                if let next {
                    standardPipeline.write(content: "    ↳ \(next.formatted(theme: theme, terminal: terminal))\n")
                }
            }
        }
    }
}
