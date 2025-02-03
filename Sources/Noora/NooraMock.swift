#if DEBUG
    public enum NooraMockEvent: Equatable {
        case success(SuccessAlert), error(ErrorAlert), warning([WarningAlert])
    }

    public class NooraMock: Noorable {
        public var events: [NooraMockEvent] = []

        public init() {}

        public func singleChoicePrompt<T>(question _: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
            T: Equatable
        {
            fatalError()
        }

        public func singleChoicePrompt<T>(
            title _: TerminalText?,
            question _: TerminalText,
            description _: TerminalText?,
            collapseOnSelection _: Bool
        ) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
            fatalError()
        }

        public func yesOrNoChoicePrompt(title _: TerminalText?, question _: TerminalText) -> Bool {
            fatalError()
        }

        public func yesOrNoChoicePrompt(
            title _: TerminalText?,
            question _: TerminalText,
            defaultAnswer _: Bool,
            description _: TerminalText?,
            collapseOnSelection _: Bool
        ) -> Bool {
            fatalError()
        }

        public func success(_ alert: SuccessAlert) {
            events.append(.success(alert))
        }

        public func error(_ alert: ErrorAlert) {
            events.append(.error(alert))
        }

        public func warning(_ alerts: WarningAlert...) {
            events.append(.warning(alerts))
        }

        public func progressStep(message _: String, action _: @escaping ((String) -> Void) async throws -> Void) async throws {
            fatalError()
        }

        public func progressStep(
            message _: String,
            successMessage _: String?,
            errorMessage _: String?,
            showSpinner _: Bool,
            action _: @escaping ((String) -> Void) async throws -> Void
        ) async throws {
            fatalError()
        }
    }
#endif
