/// A validation rule that checks if the length of a string input is within a specified range.
public struct LengthValidationRule: ValidatableRule {
    // MARK: Properties

    /// The minimum allowed length for the input string.
    let min: Int

    /// The maximum allowed length for the input string.
    let max: Int

    /// The error to return when the input's length is outside the valid range.
    public let error: ValidatableError

    // MARK: Initialization

    /// Initializes a `LengthValidationRule` with minimum and maximum length constraints.
    ///
    /// - Parameters:
    ///   - min: The minimum allowed length for the input string (default is 0).
    ///   - max: The maximum allowed length for the input string (default is Int.max).
    ///   - error: The error to return if the input length is outside the valid range.
    public init(min: Int = .zero, max: Int = .max, error: ValidatableError) {
        self.min = min
        self.max = max
        self.error = error
    }

    // MARK: ValidatableRule

    /// Validates the input string by checking if its length is within the specified range.
    ///
    /// - Parameter input: The string input to validate.
    /// - Returns: A Boolean indicating whether the input length is within the valid range.
    public func validate(input: String) -> Bool {
        let length = input.count
        return length >= min && length <= max
    }
}
