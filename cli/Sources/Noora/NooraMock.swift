#if DEBUG
    import Foundation
    import Logging
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
            standardPipelineEventsRecorder.events
                .flatMap { event in
                    // We'll use enumerated to track if we're at the end of the content
                    let lines = event.content.components(separatedBy: "\n")
                    return lines.map { line in
                        switch event.type {
                        case .error:
                            return "\(event.type): \(line)"
                        case .output:
                            return String(line)
                        }
                    }
                }
                .joined(separator: "\n")
        }

        public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
            noora = Noora(theme: theme, terminal: terminal, standardPipelines: StandardPipelines(
                output: StandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder),
                error: StandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)
            ))
        }

        /// Deletes all the recorded output.
        public func reset() {
            standardPipelineEventsRecorder.reset()
        }

        public func singleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            options: [T],
            description: TerminalText?,
            collapseOnSelection: Bool,
            filterMode: SingleChoicePromptFilterMode,
            autoselectSingleChoice: Bool,
            renderer: any Rendering
        ) -> T where T: CustomStringConvertible, T: Equatable {
            noora.singleChoicePrompt(
                title: title,
                question: question,
                options: options,
                description: description,
                collapseOnSelection: collapseOnSelection,
                filterMode: filterMode,
                autoselectSingleChoice: autoselectSingleChoice,
                renderer: renderer
            )
        }

        public func singleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            description: TerminalText?,
            collapseOnSelection: Bool,
            filterMode: SingleChoicePromptFilterMode,
            autoselectSingleChoice: Bool,
            renderer: any Rendering
        ) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
            noora.singleChoicePrompt(
                title: title,
                question: question,
                description: description,
                collapseOnSelection: collapseOnSelection,
                filterMode: filterMode,
                autoselectSingleChoice: autoselectSingleChoice,
                renderer: renderer
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

        public func info(_ alert: InfoAlert) {
            noora.info(alert)
        }

        public func table(headers: [String], rows: [[String]]) {
            noora.table(headers: headers, rows: rows)
        }

        public func warning(_ alerts: WarningAlert...) {
            warning(alerts)
        }

        public func warning(_ alerts: [WarningAlert]) {
            noora.warning(alerts)
        }

        public func progressStep<V>(message: String, task: @escaping ((String) -> Void) async throws -> V) async throws -> V {
            try await noora.progressStep(message: message, task: task)
        }

        public func progressStep<V>(
            message: String,
            successMessage: String?,
            errorMessage: String?,
            showSpinner: Bool,
            renderer: Rendering,
            task: @escaping ((String) -> Void) async throws -> V
        ) async throws -> V {
            try await noora.progressStep(
                message: message,
                successMessage: successMessage,
                errorMessage: errorMessage,
                showSpinner: showSpinner,
                renderer: renderer,
                task: task
            )
        }

        public func collapsibleStep(
            title: TerminalText,
            successMessage: TerminalText?,
            errorMessage: TerminalText?,
            visibleLines: UInt,
            renderer: Rendering,
            task: @escaping (@escaping (TerminalText) -> Void) async throws -> Void
        ) async throws {
            try await noora.collapsibleStep(
                title: title,
                successMessage: successMessage,
                errorMessage: errorMessage,
                visibleLines: visibleLines,
                renderer: renderer,
                task: task
            )
        }

        public func progressBarStep<V>(
            message: String,
            successMessage: String?,
            errorMessage: String?,
            renderer: Rendering,
            task: @escaping (@escaping (Double) -> Void) async throws -> V
        ) async throws -> V {
            try await noora.progressBarStep(
                message: message,
                successMessage: successMessage,
                errorMessage: errorMessage,
                renderer: renderer,
                task: task
            )
        }

        public func format(_ terminalText: TerminalText) -> String {
            noora.format(terminalText)
        }

        private class StandardPipelineEventsRecorder {
            var events: [StandardOutputEvent] = []
            func reset() {
                events.removeAll()
            }
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
                eventsRecorder.events.append(.init(
                    type: type,
                    content: content.removingAllStyles().trimmingSuffix(in: .whitespacesAndNewlines)
                ))
            }
        }
    }

    extension String {
        fileprivate func trimmingSuffix(in characterSet: CharacterSet) -> String {
            let reversedTrimmed = reversed().drop(while: {
                $0.unicodeScalars.allSatisfy { characterSet.contains($0) }
            })
            return String(reversedTrimmed.reversed())
        }
    }
#endif
