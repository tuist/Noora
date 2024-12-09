import Foundation
import Rainbow

public enum CompletionItem: Hashable, Equatable {
    public enum Message: Equatable, Hashable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        indirect case string(TerminalText, next: TerminalText? = nil)
        indirect case list([Message])

        public init(stringLiteral value: String) {
            self = .string(.init(components: [.raw(value)]))
        }

        public init(arrayLiteral elements: String...) {
            self = .list(elements.map { Message.string(.init(components: [.raw($0)])) })
        }

        var textAndNext: (text: TerminalText, next: TerminalText?)? {
            switch self {
            case let .string(text, next): return (text, next)
            case .list: return nil
            }
        }
    }

    case warning(Message)
    case success(Message)
    case error(Message)

    indirect case compound(Set<CompletionItem>)

    var message: Message {
        switch self {
        case let .warning(message): return message
        case let .success(success): return success
        case let .error(error): return error
        default: fatalError("Trying to obtain a message from a compound item")
        }
    }

    var flattened: Set<CompletionItem> {
        switch self {
        case let .compound(items): return items
        default: return Set([self])
        }
    }
}

struct Completion {
    let item: CompletionItem
    let standardPipelines: StandardPipelines
    let terminal: Terminaling
    let theme: Theme

    func run() {
        let flattened = item.flattened
        for (index, item) in flattened.enumerated() {
            let textAndNexts: [(text: TerminalText, next: TerminalText?)] = switch item.message {
            case let .list(messages): messages.map(\.textAndNext!)
            case .string: [item.message.textAndNext!]
            }

            if textAndNexts.isEmpty { continue }

            let standardPipeline = switch item {
            case .error: standardPipelines.error
            default: standardPipelines.output
            }

            let (title, color) = switch item {
            case .error: ("[ Error ]", theme.danger)
            case .warning: ("[ Warning ]", theme.accent)
            case .success: ("[ Success ]", theme.success)
            case .compound: fatalError("Unexpected nested compound message inside another compound message.")
            }

            standardPipeline.write(content: "\(title)\n".boldIfColoredTerminal(terminal).hexIfColoredTerminal(color, terminal))

            if textAndNexts.count == 1 {
                let (text, next) = textAndNexts.first!
                standardPipeline.write(content: "\(text.description) \n".hexIfColoredTerminal(color, terminal))
                if let next {
                    standardPipeline.write(content: "\n  Suggestion: \n".hexIfColoredTerminal(color, terminal))
                    for nextLine in next.description.split(separator: "\n") {
                        standardPipeline.write(content: "    ▸ \(nextLine)\n".hexIfColoredTerminal(color, terminal))
                    }
                }
            } else {
                for (index, (text, next)) in textAndNexts.enumerated() {
                    standardPipeline
                        .write(content: "  ▸ \(index + 1). \(text.description) \n".hexIfColoredTerminal(color, terminal))
                    if let next {
                        for (nextLineIndex, nextLine) in next.description.split(separator: "\n").enumerated() {
                            if nextLineIndex == 0 {
                                standardPipeline.write(content: "     ↳ \(nextLine) \n".hexIfColoredTerminal(color, terminal))
                            } else {
                                standardPipeline.write(content: "       \(nextLine) \n".hexIfColoredTerminal(color, terminal))
                            }
                        }
                    }
                }
            }

            if index < flattened.count - 1 {
                standardPipelines.output.write(content: "\n")
            }
        }
    }
}
