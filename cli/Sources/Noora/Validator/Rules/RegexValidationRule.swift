import Foundation

/// A validation rule that checks if a string input matches a specified regular expression pattern.
public struct RegexValidationRule: ValidatableRule {
    // MARK: Properties

    /// The regular expression pattern used for validation.
    let pattern: String

    /// The error to return when the input fails validation.
    public let error: ValidatableError

    // MARK: Initialization

    /// Initializes a `RegexValidationRule` with a given pattern and error.
    ///
    /// - Parameters:
    ///   - pattern: The regular expression pattern to match against the input.
    ///   - error: The error to return if the validation fails.
    public init(pattern: String, error: ValidatableError) {
        self.pattern = pattern
        self.error = error
    }

    // MARK: ValidatableRule

    /// Validates the input string against the regular expression pattern.
    ///
    /// - Parameter input: The string input to validate.
    ///
    /// - Returns: A Boolean indicating whether the input matches the pattern.
    public func validate(input: String) -> Bool {
        do {
            let range = NSRange(location: 0, length: input.utf16.count)
            let regex = try NSRegularExpression(pattern: pattern)
            return regex.firstMatch(in: input, options: [], range: range) != nil
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}
