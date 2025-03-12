import Testing
@testable import Noora

struct NonEmptyValidationRuleTests {
    @Test func nonEmptyValidationRuleReturnFalseWhenInputIsEmpty() {
        // given
        let subject = NonEmptyValidationRule(error: "The value is empty")

        // when
        let value = subject.validate(input: "")

        // then
        #expect(value == false)
    }

    @Test func nonEmptyValidationRuleReturnTrueWhenInputIsNotEmpty() {
        // given
        let subject = NonEmptyValidationRule(error: "The value is empty")

        // when
        let value = subject.validate(input: "input value")

        // then
        #expect(value == true)
    }
}
