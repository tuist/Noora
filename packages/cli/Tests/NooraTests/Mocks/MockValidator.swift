@testable import Noora

final class MockValidator: InputValidating {
    var invokedValidateInputRule = false
    var invokedValidateInputRuleCount = 0
    var invokedValidateInputRuleParameters: (input: String, rule: ValidatableRule)?
    var invokedValidateInputRuleParametersList = [(input: String, rule: ValidatableRule)]()
    var stubbedValidateInputRuleResult: Result<Void, ValidationError> = .success(())

    func validate(input: String, rule: ValidatableRule) -> Result<Void, ValidationError> {
        invokedValidateInputRule = true
        invokedValidateInputRuleCount += 1
        invokedValidateInputRuleParameters = (input, rule)
        invokedValidateInputRuleParametersList.append((input, rule))
        return stubbedValidateInputRuleResult
    }

    var invokedValidateInputRules = false
    var invokedValidateInputRulesCount = 0
    var invokedValidateInputRulesParameters: (input: String, rules: [ValidatableRule])?
    var invokedValidateInputRulesParametersList = [(input: String, rules: [ValidatableRule])]()
    var stubbedValidateInputRulesResult: Result<Void, ValidationError> = .success(())

    func validate(input: String, rules: [ValidatableRule]) -> Result<Void, ValidationError> {
        invokedValidateInputRules = true
        invokedValidateInputRulesCount += 1
        invokedValidateInputRulesParameters = (input, rules)
        invokedValidateInputRulesParametersList.append((input, rules))
        return stubbedValidateInputRulesResult
    }
}
