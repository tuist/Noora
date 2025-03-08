enum ValidationResult {
    /// Indicates that the validation was successful.
    case valid

    /// Indicates that the validation failed with a list of errors.
    ///
    /// - Parameter errors: An array of validation errors.
    case invalid(errors: [ValidatableError])
}
