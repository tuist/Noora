#if DEBUG
    import Rainbow

    public class MockNoora: Noora, CustomStringConvertible {
        public var description: String {
            standardPipelineEventsRecorder.events.map { event in
                event.content.split(separator: "\n")
                    .map {
                        "\(event.type): \($0)"
                    }.joined(separator: "\n")
            }.joined(separator: "\n")
        }

        var standardPipelineEventsRecorder = StandardPipelineEventsRecorder()

        public init() {
            super.init(standardPipelines: StandardPipelines(
                output: MockStandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder),
                error: MockStandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)
            ))
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

        public func write(content: String) {
            eventsRecorder.events.append(.init(type: type, content: content.removingAllStyles()))
        }
    }
#endif
