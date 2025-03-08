/// A protocol that defines a validation rule.
///
/// The `ValidatableRule` protocol allows for defining custom validation rules that can be applied to an input of type `Input`.
/// The protocol requires a property `error` that describes the validation error when the rule fails,
/// and a method `validate(input:)` to perform the validation and return whether the input is valid or not.
public protocol ValidatableRule<Input> {
    
    /// The type of input that this validation rule applies to.
    associatedtype Input
    
    /// The error that will be returned if the validation fails.
    ///
    /// This property represents the error associated with this validation rule,
    /// and it will be used when the validation does not pass.
    var error: ValidatableError { get }
    
    /// Validates the provided input and checks if it satisfies the validation rule.
    ///
    /// - Parameter input: The input to validate, of type `Input`.
    /// - Returns: A boolean indicating whether the input passes the validation (`true`) or not (`false`).
    func validate(input: Input) -> Bool
}
