import Testing

@testable import Noora

struct DisplayWidthTests {
    @Test func measures_common_widths() {
        #expect("abc".displayWidth == 3)
        #expect("✓".displayWidth == 1)
        #expect("😀".displayWidth == 2)
        #expect("🇺🇸".displayWidth == 2)
        #expect("界".displayWidth == 2)
        #expect("👨‍👩‍👦".displayWidth == 2)
        #expect("👨‍👩‍👦界🇺🇸".displayWidth == 6)
        #expect("👨‍👩‍👦界🇺🇸abc".displayWidth == 9)
        #expect(TerminalText(stringLiteral: "😀").displayWidth == 2)
        #expect(TerminalText(components: [.muted("😀")]).displayWidth == 2)
        #expect(TerminalText(components: [.info("abc")]).displayWidth == 3)
    }

    @Test func truncates_by_display_width() {
        let emojiTrimmed = "😀abc".truncated(toDisplayWidth: 3)
        #expect(emojiTrimmed == "😀a")

        let zwjTrimmed = "👨‍👩‍👦abc".truncated(toDisplayWidth: 2)
        #expect(zwjTrimmed == "👨‍👩‍👦")

        let cjkTrimmed = "界界abc".truncated(toDisplayWidth: 4)
        #expect(cjkTrimmed == "界界")
    }
}
