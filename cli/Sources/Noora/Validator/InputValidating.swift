/// A protocol defining methods for validating input against validation rules.
protocol InputValidating {
    /// Validates the input against a single validation rule.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rule: A validation rule to apply on the input.
    ///
    /// - Returns: A `Result` indicating whether the input is valid or invalid, including associated errors if any.
    func validate(input: String, rule: some ValidatableRule) -> Result<Void, ValidationError>

    /// Validates the input against a list of validation rules.
    ///
    /// - Parameters:
    ///   - input: The data that needs to be validated.
    ///   - rules: A list of validation rules to apply on the input.
    ///
    /// - Returns: A `Result` indicating whether the input is valid or invalid, including associated errors if any.
    func validate(input: String, rules: [ValidatableRule]) -> Result<Void, ValidationError>
}

extension InputValidating {
    func validate(input: String, rule: some ValidatableRule) -> Result<Void, ValidationError> {
        validate(input: input, rules: [rule])
    }
}
