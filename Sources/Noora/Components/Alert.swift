import Foundation
import Rainbow

enum AlertItem {
    case warning([(TerminalText, nextSteps: TerminalText?)])
    case success(TerminalText, nextSteps: [TerminalText] = [])
    case error(TerminalText, nextSteps: [TerminalText] = [])
}

struct Alert {
    let item: AlertItem
    let standardPipelines: StandardPipelines
    let terminal: Terminaling
    let theme: Theme

    func run() {
        let standardPipeline = switch item {
        case .error: standardPipelines.error
        default: standardPipelines.output
        }

        let (title, color, recommendedTitle) = switch item {
        case .error: ("▌ ✖ Error ", theme.danger, "Sorry this didn’t work. Here’s what to try next")
        case .warning: ("▌ ! Warning ", theme.accent, "Recommended action")
        case .success: ("▌ ✔ Success ", theme.success, "Recommended next steps")
        }

        let leftBar = "▌".hexIfColoredTerminal(color, terminal)

        standardPipeline.write(content: "\(title)\n".boldIfColoredTerminal(terminal).hexIfColoredTerminal(color, terminal))

        switch item {
        case let .error(message, nextSteps), let .success(message, nextSteps: nextSteps):
            standardPipeline.write(content: "\(leftBar) \(message.formatted(theme: theme, terminal: terminal)) \n")
            if !nextSteps.isEmpty {
                standardPipeline.write(content: "\(leftBar)\n\(leftBar) \(recommendedTitle.boldIfColoredTerminal(terminal)): \n")
                for nextItem in nextSteps {
                    standardPipeline.write(content: "\(leftBar)  ▸ \(nextItem.formatted(theme: theme, terminal: terminal))\n")
                }
            }
        case let .warning(messages):
            standardPipeline.write(content: "\(leftBar)\n\(leftBar) \(recommendedTitle.boldIfColoredTerminal(terminal)): \n")
            for (message, next) in messages {
                standardPipeline.write(content: "\(leftBar)  ▸ \(message.formatted(theme: theme, terminal: terminal))\n")
                if let next {
                    standardPipeline.write(content: "\(leftBar)   ↳ \(next.formatted(theme: theme, terminal: terminal))\n")
                }
            }
        }
    }
}
