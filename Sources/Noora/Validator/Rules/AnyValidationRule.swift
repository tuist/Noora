/// A wrapper for any validation rule that can be applied to an input of type `Input`.
struct AnyValidationRule: ValidatableRule {
    
    // MARK: Properties
    
    /// The error associated with the validation rule when it fails.
    let error: ValidatableError

    /// A closure that performs the validation on the input.
    private let validationInput: (String) -> Bool

    // MARK: Initialization
    
    /// Initializes an `AnyValidationRule` with a specific validation rule.
    init<Rule: ValidatableRule>(validationRule: Rule) {
        validationInput = validationRule.validate(input:)
        error = validationRule.error
    }
    
    // MARK: ValidatableRule
    
    /// Validates the input using the encapsulated validation logic.
    ///
    /// - Parameter input: The data to validate.
    /// - Returns: A Boolean indicating whether the input is valid according to the rule.
    func validate(input: String) -> Bool {
        validationInput(input)
    }
}
