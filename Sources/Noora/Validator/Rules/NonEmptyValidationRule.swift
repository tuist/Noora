import Foundation

/// A validation rule that checks if a string input is non-empty (i.e., not an empty string).
public struct NonEmptyValidationRule: ValidatableRule {
    // MARK: Properties

    /// The error to return when the input is empty.
    public let error: ValidatableError

    // MARK: Initialization

    /// Initializes a `NonEmptyValidationRule` with a specified error.
    ///
    /// - Parameter error: The error to return if the input is empty.
    public init(error: ValidatableError) {
        self.error = error
    }

    // MARK: ValidatableRule

    /// Validates the input string to check if it is non-empty.
    ///
    /// - Parameter input: The string input to validate.
    /// - Returns: A Boolean indicating whether the input is non-empty.
    public func validate(input: String) -> Bool {
        !input.isEmpty
    }
}
