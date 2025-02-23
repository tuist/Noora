#if DEBUG
    import Rainbow

    /// A test instance of `Noora` that records all standard output and error events
    /// for verification in tests.
    ///
    /// # Usage
    ///
    /// When instantiating Noora in your test environment, instead of using `Noora` itself, use `NooraMock`.
    ///
    /// ```swift
    /// let ui = NooraMock()
    /// ```
    ///
    /// Then, inside your tests, you can assert on the recorded output.
    ///
    /// ```swift
    /// #expect(ui.description == """
    ///     stderr: ▌ ✖ Error
    ///     stderr: ▌ That didn't work. Please try again.
    /// """)
    ///
    /// `description` contains all output made via Noora, with each line prefixed by the output type (`stdout`/`stderr`).
    /// ```

    public struct NooraMock: Noorable,
        CustomStringConvertible
    {
        private let noora: Noorable
        private var standardPipelineEventsRecorder = StandardPipelineEventsRecorder()

        public var description: String {
            standardPipelineEventsRecorder.events.map { event in
                event.content.split(separator: "\n")
                    .map {
                        switch event.type {
                        case .error:
                            "\(event.type): \($0)".trimmingCharacters(in: .whitespaces)
                        case .output:
                            $0.trimmingCharacters(in: .whitespaces)
                        }

                    }.joined(separator: "\n")
            }.joined(separator: "\n")
        }

        public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
            noora = Noora(theme: theme, terminal: terminal, standardPipelines: StandardPipelines(
                output: StandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder),
                error: StandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)
            ))
        }

        public func singleChoicePrompt<T>(question: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
            T: Equatable
        {
            noora.singleChoicePrompt(question: question)
        }

        public func singleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            description: TerminalText?,
            collapseOnSelection: Bool
        ) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
            noora.singleChoicePrompt(
                title: title,
                question: question,
                description: description,
                collapseOnSelection: collapseOnSelection
            )
        }

        public func yesOrNoChoicePrompt(title: TerminalText?, question: TerminalText) -> Bool {
            noora.yesOrNoChoicePrompt(title: title, question: question)
        }

        public func yesOrNoChoicePrompt(
            title: TerminalText?,
            question: TerminalText,
            defaultAnswer: Bool,
            description: TerminalText?,
            collapseOnSelection: Bool
        ) -> Bool {
            noora.yesOrNoChoicePrompt(
                title: title,
                question: question,
                defaultAnswer: defaultAnswer,
                description: description,
                collapseOnSelection: collapseOnSelection
            )
        }

        public func success(_ alert: SuccessAlert) {
            noora.success(alert)
        }

        public func error(_ alert: ErrorAlert) {
            noora.error(alert)
        }

        public func warning(_ alerts: WarningAlert...) {
            warning(alerts)
        }

        public func warning(_ alerts: [WarningAlert]) {
            noora.warning(alerts)
        }

        public func progressStep(message: String, task: @escaping ((String) -> Void) async throws -> Void) async throws {
            try await noora.progressStep(message: message, task: task)
        }

        public func progressStep(
            message: String,
            successMessage: String?,
            errorMessage: String?,
            showSpinner: Bool,
            task: @escaping ((String) -> Void) async throws -> Void
        ) async throws {
            try await noora.progressStep(
                message: message,
                successMessage: successMessage,
                errorMessage: errorMessage,
                showSpinner: showSpinner,
                task: task
            )
        }

        public func collapsibleStep(
            title: TerminalText,
            successMessage: TerminalText?,
            errorMessage: TerminalText?,
            visibleLines: UInt,
            task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
        ) async throws {
            try await noora.collapsibleStep(
                title: title,
                successMessage: successMessage,
                errorMessage: errorMessage,
                visibleLines: visibleLines,
                task: task
            )
        }

        public func format(_ terminalText: TerminalText) -> String {
            noora.format(terminalText)
        }

        private class StandardPipelineEventsRecorder {
            var events: [StandardOutputEvent] = []
        }

        private struct StandardOutputEvent: Equatable {
            let type: StandardPipelineType
            let content: String
        }

        private enum StandardPipelineType: CustomStringConvertible {
            public var description: String {
                switch self {
                case .error: "stderr"
                case .output: "stdout"
                }
            }

            case output
            case error
        }

        private struct StandardPipeline: StandardPipelining {
            let type: StandardPipelineType
            let eventsRecorder: StandardPipelineEventsRecorder

            public func write(content: String) {
                eventsRecorder.events.append(.init(type: type, content: content.removingAllStyles()))
            }
        }
    }
#endif
