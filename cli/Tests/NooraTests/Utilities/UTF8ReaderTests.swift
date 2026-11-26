import Testing

@testable import Noora

struct UTF8ReaderTests {
    @Test(arguments: TestCase.allCases)
    func decodesSingleCharacter(testCase: TestCase) {
        var iter = testCase.bytes.makeIterator()
        let reader = UTF8Reader { iter.next() }
        #expect(reader.readCharacter() == testCase.expected)
    }

    @Test
    func readsConsecutiveCharactersWithoutByteLeakage() {
        let bytes: [UInt8] = [
            0x41, // A (1-byte)
            0xC3, 0xA9, // é (2-byte)
            0xE4, 0xB8, 0xAD, // 中 (3-byte)
            0xF0, 0x9F, 0x98, 0x80, // 😀 (4-byte)
        ]
        var iter = bytes.makeIterator()
        let reader = UTF8Reader { iter.next() }

        #expect(reader.readCharacter() == "A")
        #expect(reader.readCharacter() == "é")
        #expect(reader.readCharacter() == "中")
        #expect(reader.readCharacter() == "😀")
        #expect(reader.readCharacter() == nil)
    }

    struct TestCase: CustomTestStringConvertible, Sendable {
        let bytes: [UInt8]
        let expected: Character?
        let testDescription: String

        static let allCases: [TestCase] = [
            // 1-byte sequences (ASCII)
            TestCase(bytes: [0x41], expected: "A", testDescription: "ASCII letter"),
            TestCase(bytes: [0x00], expected: "\0", testDescription: "null character"),
            TestCase(bytes: [0x7F], expected: "\u{7F}", testDescription: "ASCII max (DEL)"),

            // 2-byte sequences
            TestCase(bytes: [0xC3, 0xA9], expected: "é", testDescription: "Latin: French e-acute"),
            TestCase(bytes: [0xD0, 0x90], expected: "А", testDescription: "Cyrillic: Russian A"),

            // 3-byte sequences
            TestCase(bytes: [0xE3, 0x81, 0x82], expected: "あ", testDescription: "Japanese hiragana"),
            TestCase(bytes: [0xE4, 0xB8, 0xAD], expected: "中", testDescription: "Chinese hanzi"),
            TestCase(bytes: [0xEA, 0xB0, 0x80], expected: "가", testDescription: "Korean hangul"),
            TestCase(bytes: [0xE2, 0x82, 0xAC], expected: "€", testDescription: "Euro sign"),

            // 4-byte sequences
            TestCase(bytes: [0xF0, 0x9F, 0x98, 0x80], expected: "😀", testDescription: "Emoji"),
            TestCase(bytes: [0xF0, 0x9F, 0x87, 0xAF], expected: "🇯", testDescription: "Regional indicator J"),

            // Invalid sequences
            TestCase(bytes: [0x80], expected: nil, testDescription: "Invalid: lone continuation byte"),
            TestCase(bytes: [0xFF], expected: nil, testDescription: "Invalid: 0xFF is never valid"),
            TestCase(bytes: [0xC3], expected: nil, testDescription: "Invalid: incomplete 2-byte sequence"),
            TestCase(bytes: [0xE3, 0x81], expected: nil, testDescription: "Invalid: incomplete 3-byte sequence"),
            TestCase(bytes: [0xF0, 0x9F, 0x98], expected: nil, testDescription: "Invalid: incomplete 4-byte sequence"),
            TestCase(bytes: [0xC0, 0x80], expected: nil, testDescription: "Invalid: overlong encoding"),
            TestCase(bytes: [0xF5, 0x80, 0x80, 0x80], expected: nil, testDescription: "Invalid: exceeds Unicode range"),
            TestCase(bytes: [0xC3, 0x00], expected: nil, testDescription: "Invalid: bad continuation byte"),

            // Empty input
            TestCase(bytes: [], expected: nil, testDescription: "Empty input"),
        ]
    }
}
