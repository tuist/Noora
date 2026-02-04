#if hasFeature(RetroactiveAttribute)
    extension String: @retroactive Error {}
#endif

// MARK: - String + ValidatableError

extension String: ValidatableError {
    public var message: String {
        self
    }
}
