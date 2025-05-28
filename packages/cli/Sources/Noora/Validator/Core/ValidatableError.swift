/// A protocol that represents an error associated with a validation rule.
///
/// The `ValidatableError` protocol defines the structure for validation errors. Any custom error that conforms to this protocol
/// should provide a `message` property that contains a description of the error, which is typically used to inform the user
/// about why the validation failed.
public protocol ValidatableError: Error {
    /// A message describing the validation error.
    ///
    /// This property should contain a human-readable message that explains why the validation failed,
    /// providing useful information to the user or developer.
    var message: String { get }
}
