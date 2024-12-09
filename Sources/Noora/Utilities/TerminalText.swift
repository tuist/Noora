import Foundation

/// Terminal text represents a piece of texts where some elements have semantics
/// that are used to format the text when it's output to the user based on the terminal
/// capabilities.
public struct TerminalText: CustomStringConvertible, Equatable, Hashable {
    public enum Component: Equatable, Hashable {
        /// A string with no special semantics in the context of terminal text.
        case raw(String)
        /// A string that represents a system command (e.g. 'tuist generate')
        case command(String)
    }

    /// Every component of the interpolated string.
    var components: [Component]

    public var description: String {
        var output = ""
        for component in components {
            switch component {
            case let .raw(rawString): output.append(rawString)
            case let .command(command): output.append("'\(command)'")
            }
        }
        return output
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
