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

        /// A string with the theme's primary color
        case primary(String)
        /// A string with the theme's secondary color
        case secondary(String)
        /// A string with the theme's muted color
        case muted(String)
        /// A string with the theme's accent color
        case accent(String)
        /// A string with the theme's danger color
        case danger(String)
        /// A string with the theme's success color
        case success(String)
    }

    /// Every component of the interpolated string.
    let components: [Component]

    public func formatted(theme: Theme, terminal: Terminaling) -> String {
        components.map { component in
            switch component {
            case let .raw(rawString): rawString
            case let .command(command): "'\(command)'".hexIfColoredTerminal(theme.secondary, terminal)
            case let .primary(primary): primary.hexIfColoredTerminal(theme.primary, terminal)
            case let .secondary(secondary): secondary.hexIfColoredTerminal(theme.secondary, terminal)
            case let .muted(muted): muted.hexIfColoredTerminal(theme.muted, terminal)
            case let .accent(accent): accent.hexIfColoredTerminal(theme.accent, terminal)
            case let .danger(danger): danger.hexIfColoredTerminal(theme.danger, terminal)
            case let .success(success): success.hexIfColoredTerminal(theme.success, terminal)
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
