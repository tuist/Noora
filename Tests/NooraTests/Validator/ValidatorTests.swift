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
        case .success:
            #expect(true)
        case .failure:
            Issue.record("The result must be equal to success.")
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
        case .success:
            Issue.record("The result must be equal to failure.")
        case let .failure(error):
            #expect(error.errors.count == 1)
            #expect(error.errors.first?.message == "Input can't be empty")
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
        case .success:
            #expect(true)
        case .failure:
            Issue.record("The result must be equal to success.")
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
        case .success:
            Issue.record("The result must be equal to failure.")
        case let .failure(error):
            #expect(error.errors.count == 2)
            #expect(error.errors.contains { $0.message == "Input cannot be empty" })
            #expect(error.errors.contains { $0.message == "Length out of range" })
        }
    }
}
