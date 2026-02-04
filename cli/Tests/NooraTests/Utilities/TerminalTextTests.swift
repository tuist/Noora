@preconcurrency import Rainbow
import Testing

@testable import Noora

@Suite(.serialized)
struct TerminalTextTests {
    @Test func commandsAreFormattedBetweenSingleQuotes() {
        // Given
        let subject: TerminalText = "Please run \(.command("tuist project tokens create")) to obtain a new token."

        // When
        let got = subject.formatted(theme: .default, terminal: Terminal(isInteractive: false, isColored: true))

        // Then
        #expect(got == "Please run 'tuist project tokens create' to obtain a new token.")
    }

    @Test func linksAreNotFormattedWhenNonInteractiveTerminal() {
        // Given
        let subject: TerminalText = "Visit \(.link(title: "Tuist", href: "https://tuist.dev"))"

        // When
        let got = subject.formatted(theme: .default, terminal: Terminal(isInteractive: false, isColored: true))

        // Then
        #expect(got == "Visit <Tuist: https://tuist.dev>")
    }

    @Test func terminalTextIsFormattedWithTheme() {
        // Force Rainbow to apply colors to the output
        let enabled = Rainbow.enabled
        let outputTarget = Rainbow.outputTarget
        Rainbow.enabled = true
        Rainbow.outputTarget = .console
        defer {
            Rainbow.enabled = enabled
            Rainbow.outputTarget = outputTarget
        }

        // Given
        let noora = Noora(theme: .default, terminal: Terminal(isInteractive: false, isColored: true))
        let terminalText = TerminalText("""
        \(.raw("A string with no special semantics in the context of terminal text."))
        \(.command("a-string-that-represents-a-system-command"))
        \(.primary("A string with the theme's primary color"))
        \(.secondary("A string with the theme's secondary color"))
        \(.muted("A string with the theme's muted color"))
        \(.accent("A string with the theme's accent color"))
        \(.danger("A string with the theme's danger color"))
        \(.success("A string with the theme's success color"))
        \(.info("A string with the theme's info color"))
        """)

        // When
        let formattedText = noora.format(terminalText)

        // Then
        #expect(formattedText == """
        A string with no special semantics in the context of terminal text.
        \u{1B}[38;5;205m'a-string-that-represents-a-system-command'\u{1B}[0m
        \u{1B}[38;5;141mA string with the theme's primary color\u{1B}[0m
        \u{1B}[38;5;205mA string with the theme's secondary color\u{1B}[0m
        \u{1B}[38;5;59mA string with the theme's muted color\u{1B}[0m
        \u{1B}[38;5;172mA string with the theme's accent color\u{1B}[0m
        \u{1B}[38;5;196mA string with the theme's danger color\u{1B}[0m
        \u{1B}[38;5;107mA string with the theme's success color\u{1B}[0m
        \u{1B}[38;5;38mA string with the theme's info color\u{1B}[0m
        """)
    }

    @Test func descriptionUsesPlainText() {
        let subject: TerminalText = "Visit \(.link(title: "Tuist", href: "https://tuist.dev")) and run \(.command("tuist"))"

        #expect(String(describing: subject) == "Visit (Tuist) and run 'tuist'")
    }
}
