import Foundation

/// A custom error type that aggregates multiple validation errors.
struct ValidationError: Error {
    /// An array of validation errors that occurred.
    let errors: [ValidatableError]
}
