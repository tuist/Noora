import Foundation
import Logging
import Rainbow

enum AlertItem {
    case warning([(TerminalText, takeaway: TerminalText?)])
    case success(TerminalText, takeaways: [TerminalText] = [])
    case error(TerminalText, takeaways: [TerminalText] = [])
    case info(TerminalText, takeaways: [TerminalText] = [])

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
    let localization: Localization
    let logger: Logger?

    func run() {
        let standardPipeline = switch item {
        case .error: standardPipelines.error
        default: standardPipelines.output
        }

        let (title, color, recommendedTitle) = switch item {
        case .error: ("\(localization.errorAlertTitle) ", theme.danger, localization.errorAlertRecommendedTitle)
        case .warning: ("\(localization.warningAlertTitle) ", theme.accent, localization.warningAlertRecommendedTitle)
        case .success: ("\(localization.successAlertTitle) ", theme.success, localization.successAlertRecommendedTitle)
        case .info: ("\(localization.infoAlertTitle) ", theme.info, localization.infoAlertRecommendedTitle)
        }

        standardPipeline.write(content: "\(title)\n".boldIfColoredTerminal(terminal).hexIfColoredTerminal(color, terminal))

        switch item {
        case let .error(message, takeaways), let .success(message, takeaways: takeaways),
             let .info(message, takeaways: takeaways):
            for messageLine in message.formatted(theme: theme, terminal: terminal).split(separator: "\n") {
                standardPipeline.write(content: "  \(messageLine) \n")
            }
            var logMessage = """
            \(item.isSuccess ? "Success" : "Error") alert: \(title)
              - Message: \(message)
            """
            if !takeaways.isEmpty {
                standardPipeline.write(content: "\n  \(recommendedTitle.boldIfColoredTerminal(terminal)): \n")
                logMessage = """
                \(logMessage)
                  - Takeaways:
                \(takeaways.map { "    - \($0)" }.joined(separator: "\n"))
                """
                for takeaway in takeaways {
                    for (nextItemIndex, nextItemLine) in takeaway.formatted(theme: theme, terminal: terminal)
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
