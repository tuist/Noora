import Foundation
import Rainbow

struct TextPrompt {
    let title: TerminalText?
    let prompt: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnAnswer: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines

    func run() -> String {
        if !terminal.isInteractive {
            fatalError("'\(prompt)' can't be prompted in a non-interactive session.")
        }

        var input = ""

        terminal.withoutCursor {
            render(input: input)
            while let character = getCharacter(), character != "\n" {
                input.append(character)
                render(input: input)
            }
        }

        render(input: input, withCursor: false)

        return input
    }

    private func render(input: String, withCursor: Bool = true) {
        let titleOffset = title != nil ? "  " : ""

        var content = ""
        if let title {
            content = title.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        let input = "\(input)\(withCursor ? "\u{1B}[5m█\u{1B}[0m" : "")".hexIfColoredTerminal(theme.secondary, terminal)

        content += "\(title != nil ? "\n" : "")\(titleOffset)\(prompt.formatted(theme: theme, terminal: terminal)) \(input)"

        if let description {
            content +=
                "\n\(titleOffset)\(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }

        renderer.render(content, standardPipeline: standardPipelines.output)
    }

    private func getCharacter() -> Character? {
        var term = termios()
        tcgetattr(fileno(stdin), &term) // Get terminal attributes
        var original = term

        term.c_lflag &= ~UInt(ECHO | ICANON) // Disable echo & canonical mode
        tcsetattr(fileno(stdin), TCSANOW, &term) // Apply changes

        let char = getchar() // Read single character

        tcsetattr(fileno(stdin), TCSANOW, &original) // Restore original settings
        return char != EOF ? Character(UnicodeScalar(UInt8(char))) : nil
    }
}
