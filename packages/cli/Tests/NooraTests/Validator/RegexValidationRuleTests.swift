import Testing
@testable import Noora

struct RegexValidationRuleTests {
    @Test func regexValidationRuleReturnTrueWhenInputMatchesPattern() {
        // given
        let subject = RegexValidationRule(pattern: "^[a-zA-Z]+$", error: "Invalid input")
        let input = "Hello"

        // when
        let result = subject.validate(input: input)

        // then
        #expect(result == true)
    }

    @Test func regexValidationRuleReturnFalseWhenInputDoesNotMatchPattern() {
        // given
        let subject = RegexValidationRule(pattern: "^[a-zA-Z]+$", error: "Invalid input")
        let input = "Hello123"

        // when
        let result = subject.validate(input: input)

        // then
        #expect(result == false)
    }

    @Test func regexValidationRuleReturnFalseWhenInputIsEmpty() {
        // given
        let subject = RegexValidationRule(pattern: "^[a-zA-Z]+$", error: "Input can't be empty")
        let input = ""

        // when
        let result = subject.validate(input: input)

        // then
        #expect(result == false)
    }

    @Test func regexValidationRuleReturnTrueWhenPatternAllowsDigits() {
        // given
        let subject = RegexValidationRule(pattern: "^[0-9]+$", error: "Invalid format")
        let input = "123456"

        // when
        let result = subject.validate(input: input)

        // then
        #expect(result == true)
    }

    @Test func regexValidationRuleShouldValidateCorrectlyWhenPatternRequiresEmailFormat() {
        // given
        let subject = RegexValidationRule(
            pattern: "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
            error: "Invalid email format."
        )
        let validEmail = "test@example.com"
        let invalidEmail = "test@com"

        // when
        let validResult = subject.validate(input: validEmail)
        let invalidResult = subject.validate(input: invalidEmail)

        // then
        #expect(validResult == true)
        #expect(invalidResult == false)
    }
}
