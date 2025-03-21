/// A struct responsible for validating input data against specific rules.
struct Validator {
    /// Validates the input against a single validation rule.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rule: A validation rule to apply on the input.
    ///
    /// - Returns: A `ValidationResult` indicating whether the input is valid or invalid, including the associated errors if any.
    func validate(input: String, rule: some ValidatableRule) -> Result<Void, ValidationError> {
        validate(input: input, rules: [rule])
    }

    /// Validates the input against a list of validation rules.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rules: A list of validation rules to apply on the input.
    ///
    /// - Returns: A `ValidationResult` indicating whether the input is valid or invalid, including the associated errors if any.
    func validate(input: String, rules: [ValidatableRule]) -> Result<Void, ValidationError> {
        let errors = rules
            .filter { !$0.validate(input: input) }
            .map(\.error)

        return errors.isEmpty ? .success(()) : .failure(ValidationError(errors: errors))
    }
}
