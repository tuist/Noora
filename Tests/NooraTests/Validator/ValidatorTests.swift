import Testing
@testable import Noora

struct ValidatorTests {
    @Test func validatorReturnValidWhenSingleRulePasses() {
        // given
        let subject = Validator()
        let rule = NonEmptyValidationRule(error: "Input can't be empty")
        let input = "Hello"

        // when
        let result = subject.validate(input: input, rule: rule)

        // then
        switch result {
        case .valid:
            #expect(true)
        case let .invalid(errors: errors):
            #expect(false)
        }
    }

    @Test func validatorReturnInvalidWhenSingleRuleFails() {
        // given
        let subject = Validator()
        let rule = NonEmptyValidationRule(error: "Input can't be empty")
        let input = ""

        // when
        let result = subject.validate(input: input, rule: rule)

        // then
        switch result {
        case .valid:
            #expect(false)
        case let .invalid(errors: errors):
            #expect(errors.count == 1)
            #expect(errors.first?.message == "Input can't be empty")
        }
    }

    @Test func validatorReturnValidWhenMultipleRulesPass() {
        // given
        let subject = Validator()
        let rules: [ValidatableRule] = [
            NonEmptyValidationRule(error: "Input cannot be empty"),
            LengthValidationRule(min: 3, max: 10, error: "Length out of range"),
        ]
        let input = "Hello"

        // when
        let result = subject.validate(input: input, rules: rules)

        // then
        switch result {
        case .valid:
            #expect(true)
        case .invalid:
            #expect(false)
        }
    }

    @Test func validatorReturnInvalidWithAllErrorsWhenMultipleRulesFail() {
        // given
        let subject = Validator()
        let rules: [ValidatableRule] = [
            NonEmptyValidationRule(error: "Input cannot be empty"),
            LengthValidationRule(min: 3, max: 10, error: "Length out of range"),
        ]
        let input = ""

        // when
        let result = subject.validate(input: input, rules: rules)

        // then
        switch result {
        case .valid:
            #expect(false)
        case let .invalid(errors):
            #expect(errors.count == 2)
            #expect(errors.contains { $0.message == "Input cannot be empty" })
            #expect(errors.contains { $0.message == "Length out of range" })
        }
    }
}
