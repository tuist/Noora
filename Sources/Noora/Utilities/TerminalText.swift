import Foundation

/// Terminal text represents a piece of texts where some elements have semantics
/// that are used to format the text when it's output to the user based on the terminal
/// capabilities.
public struct TerminalText: Equatable, Hashable {
    public enum Component: Equatable, Hashable {
        /// A string with no special semantics in the context of terminal text.
        case raw(String)
        /// A string that represents a system command (e.g. 'tuist generate')
        case command(String)
    }

    /// Every component of the interpolated string.
    let components: [Component]

    public func formatted(theme: Theme, terminal: Terminaling) -> String {
        components.map { component in
            switch component {
            case let .raw(rawString): rawString
            case let .command(command): "'\(command)'".hexIfColoredTerminal(theme.secondary, terminal)
            }
        }
        .joined()
    }
}

extension TerminalText: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        components = [.raw(value)]
    }

    public init(stringInterpolation: StringInterpolation) {
        components = stringInterpolation.components
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        var components: [Component]

        public init(literalCapacity _: Int, interpolationCount _: Int) {
            components = []
        }

        public mutating func appendLiteral(_ literal: String) {
            components.append(.raw(literal))
        }

        public mutating func appendInterpolation(_ value: some Any) {
            components.append(.raw(String(describing: value)))
        }

        public mutating func appendInterpolation(_ value: Component) {
            components.append(value)
        }
    }
}
