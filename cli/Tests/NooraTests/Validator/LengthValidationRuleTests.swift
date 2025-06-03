import Testing
@testable import Noora

struct LengthValidationRuleTests {
    @Test func lengthValidationRuleReturnFalseWhenInputIsTooShort() {
        // given
        let input = "abc"
        let subject = LengthValidationRule(min: 5, error: "Input is too short")

        // when
        let result = subject.validate(input: input)

        // theb
        #expect(result == false)
    }

    @Test func lengthValidationRuleReturnFalseWhenInputIsTooLong() {
        // given
        let input = "abcdefghijkl"
        let subject = LengthValidationRule(max: 10, error: "Input is too long")

        // when
        let result = subject.validate(input: input)

        // theb
        #expect(result == false)
    }

    @Test func lengthValidationRuleReturnTrueWhenInputIsWithinRange() {
        // given
        let input = "abcdef"
        let subject = LengthValidationRule(min: 5, max: 10, error: "Input is out of range")

        // when
        let result = subject.validate(input: input)

        // theb
        #expect(result == true)
    }

    @Test func lengthValidationRuleReturnTrueWhenInputIsAtMinimumLength() {
        // given
        let input = "abcde"
        let subject = LengthValidationRule(min: 5, max: 10, error: "Input is too short")

        // when
        let result = subject.validate(input: input)

        // theb
        #expect(result == true)
    }

    @Test func lengthValidationRuleReturnTrueWhenInputIsAtMaximumLength() {
        // given
        let input = "abcdefghij"
        let subject = LengthValidationRule(min: 5, max: 10, error: "Input is too long")

        // when
        let result = subject.validate(input: input)

        // theb
        #expect(result == true)
    }
}
