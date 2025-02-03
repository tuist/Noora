#if DEBUG
import Rainbow

public class MockNoora: Noora, CustomStringConvertible {
    public var description: String {
        self.standardPipelineEventsRecorder.events.map({event in
            event.content.split(separator: "\n")
                .map({
                    "\(event.type): \($0)"
                }).joined(separator: "\n")
        }).joined(separator: "\n")
    }
    
    var standardPipelineEventsRecorder = StandardPipelineEventsRecorder()
    
    public init() {
        super.init(standardPipelines: StandardPipelines(output: MockStandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder), error: MockStandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)))
    }

}

public class StandardPipelineEventsRecorder {
    var events: [MockStandardOutputEvent] = []
}

public struct MockStandardOutputEvent: Equatable {
    let type: MockStandardPipelineType
    let content: String
}

public enum MockStandardPipelineType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .error: "stderr"
        case .output: "stdout"
        }
    }
    
    case output
    case error
}

public struct MockStandardPipeline: StandardPipelining {
    let type: MockStandardPipelineType
    let eventsRecorder: StandardPipelineEventsRecorder
    
    init(type: MockStandardPipelineType, eventsRecorder: StandardPipelineEventsRecorder) {
        self.type = type
        self.eventsRecorder = eventsRecorder
    }
    
    public func write(content: String) {
        self.eventsRecorder.events.append(.init(type: type, content: content.removingAllStyles()))
    }
}



//    public enum NooraMockEvent: Equatable {
//        case success(SuccessAlert), error(ErrorAlert), warning([WarningAlert])
//    }
//
//    public class NooraMock: Noorable {
//        public var events: [NooraMockEvent] = []
//
//        public init() {}
//
//        public func singleChoicePrompt<T>(question _: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
//            T: Equatable
//        {
//            fatalError()
//        }
//
//        public func singleChoicePrompt<T>(
//            title _: TerminalText?,
//            question _: TerminalText,
//            description _: TerminalText?,
//            collapseOnSelection _: Bool
//        ) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
//            fatalError()
//        }
//
//        public func yesOrNoChoicePrompt(title _: TerminalText?, question _: TerminalText) -> Bool {
//            fatalError()
//        }
//
//        public func yesOrNoChoicePrompt(
//            title _: TerminalText?,
//            question _: TerminalText,
//            defaultAnswer _: Bool,
//            description _: TerminalText?,
//            collapseOnSelection _: Bool
//        ) -> Bool {
//            fatalError()
//        }
//
//        public func success(_ alert: SuccessAlert) {
//            events.append(.success(alert))
//        }
//
//        public func error(_ alert: ErrorAlert) {
//            events.append(.error(alert))
//        }
//
//        public func warning(_ alerts: WarningAlert...) {
//            events.append(.warning(alerts))
//        }
//
//        public func progressStep(message _: String, action _: @escaping ((String) -> Void) async throws -> Void) async throws {
//            fatalError()
//        }
//
//        public func progressStep(
//            message _: String,
//            successMessage _: String?,
//            errorMessage _: String?,
//            showSpinner _: Bool,
//            action _: @escaping ((String) -> Void) async throws -> Void
//        ) async throws {
//            fatalError()
//        }
//    }
#endif
