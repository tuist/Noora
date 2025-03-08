/// A struct responsible for validating input data against specific rules.
struct Validator {
    
    /// Validates the input against a single validation rule.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rule: A validation rule to apply on the input.
    ///
    /// - Returns: A `ValidationResult` indicating whether the input is valid or invalid, including the associated errors if any.
    func validate<Rule: ValidatableRule>(input: String, rule: Rule) -> ValidationResult {
        validate(input: input, rules: [rule])
    }

    /// Validates the input against a list of validation rules.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rules: A list of validation rules to apply on the input.
    ///
    /// - Returns: A `ValidationResult` indicating whether the input is valid or invalid, including the associated errors if any.
    func validate(input: String, rules: [ValidatableRule]) -> ValidationResult {
        let errors = rules
            .filter { !$0.validate(input: input) }
            .map { $0.error }

        return errors.isEmpty ? .valid : .invalid(errors: errors)
    }
}
