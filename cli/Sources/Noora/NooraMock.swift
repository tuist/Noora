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

    // swiftlint:disable:next type_body_length
    public struct NooraMock: Noorable,
        CustomStringConvertible
    {
        private let noora: Noorable
        private let theme: Theme
        private let terminal: Terminaling
        private var standardPipelineEventsRecorder = StandardPipelineEventsRecorder()

        public var description: String {
            standardPipelineEventsRecorder.events.withValue {
                $0.flatMap { event in
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
        }

        public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
            self.theme = theme
            self.terminal = terminal
            noora = Noora(theme: theme, terminal: terminal, standardPipelines: StandardPipelines(
                output: StandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder),
                error: StandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)
            ))
        }

        public func passthrough(_ text: TerminalText, pipeline: StandardPipelineType) {
            standardPipelineEventsRecorder.record(.init(
                type: pipeline,
                content: text.formatted(theme: theme, terminal: terminal)
            ))
        }

        public func json(_ item: some Codable, encoder: JSONEncoder) throws {
            let jsonData = try encoder.encode(item)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let text = TerminalText(stringLiteral: jsonString)
                passthrough(text, pipeline: .output)
            }
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

        public func multipleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            options: [T],
            description: TerminalText?,
            collapseOnSelection: Bool,
            filterMode: MultipleChoicePromptFilterMode,
            renderer: any Rendering
        ) -> [T] where T: CustomStringConvertible, T: Equatable {
            noora.multipleChoicePrompt(
                title: title,
                question: question,
                options: options,
                description: description,
                collapseOnSelection: collapseOnSelection,
                filterMode: filterMode,
                renderer: renderer
            )
        }

        public func multipleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            description: TerminalText?,
            collapseOnSelection: Bool,
            filterMode: MultipleChoicePromptFilterMode,
            renderer: any Rendering
        ) -> [T] where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
            noora.multipleChoicePrompt(
                title: title,
                question: question,
                description: description,
                collapseOnSelection: collapseOnSelection,
                filterMode: filterMode,
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

        public func textPrompt(
            title: TerminalText?,
            prompt: TerminalText,
            description: TerminalText?,
            collapseOnAnswer: Bool,
            renderer: Rendering,
            validationRules: [ValidatableRule]
        ) -> String {
            noora.textPrompt(
                title: title,
                prompt: prompt,
                description: description,
                collapseOnAnswer: collapseOnAnswer,
                renderer: renderer,
                validationRules: validationRules
            )
        }

        public func yesOrNoChoicePrompt(
            title: TerminalText?,
            question: TerminalText,
            defaultAnswer: Bool,
            description: TerminalText?,
            collapseOnSelection: Bool,
            renderer: Rendering
        ) -> Bool {
            noora.yesOrNoChoicePrompt(
                title: title,
                question: question,
                defaultAnswer: defaultAnswer,
                description: description,
                collapseOnSelection: collapseOnSelection,
                renderer: renderer
            )
        }

        public func table(
            headers: [String],
            rows: [[String]],
            renderer: Rendering
        ) {
            noora.table(
                headers: headers,
                rows: rows,
                renderer: renderer
            )
        }

        public func table(
            _ data: TableData,
            renderer: Rendering
        ) {
            noora.table(
                data,
                renderer: renderer
            )
        }

        public func table(
            headers: [TableCellStyle],
            rows: [StyledTableRow],
            renderer: Rendering
        ) {
            noora.table(
                headers: headers,
                rows: rows,
                renderer: renderer
            )
        }

        public func selectableTable(
            headers: [String],
            rows: [[String]],
            pageSize: Int,
            renderer: Rendering
        ) async throws -> Int {
            try await noora.selectableTable(
                headers: headers,
                rows: rows,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        public func selectableTable(
            _ data: TableData,
            pageSize: Int,
            renderer: Rendering
        ) async throws -> Int {
            try await noora.selectableTable(
                data,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        public func selectableTable(
            headers: [TableCellStyle],
            rows: [StyledTableRow],
            pageSize: Int,
            renderer: Rendering
        ) async throws -> Int {
            try await noora.selectableTable(
                headers: headers,
                rows: rows,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        public func paginatedTable(
            headers: [String],
            rows: [[String]],
            pageSize: Int,
            renderer: Rendering
        ) throws {
            try noora.paginatedTable(
                headers: headers,
                rows: rows,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        public func paginatedTable(
            _ data: TableData,
            pageSize: Int,
            renderer: Rendering
        ) throws {
            try noora.paginatedTable(
                data,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        public func paginatedTable(
            headers: [TableCellStyle],
            rows: [StyledTableRow],
            pageSize: Int,
            renderer: Rendering
        ) throws {
            try noora.paginatedTable(
                headers: headers,
                rows: rows,
                pageSize: pageSize,
                renderer: renderer
            )
        }

        private final class StandardPipelineEventsRecorder: @unchecked Sendable {
            private let lock = NSRecursiveLock()
            let events = LockIsolated([StandardOutputEvent]())

            func reset() {
                events.withValue {
                    $0.removeAll()
                }
            }

            func record(_ event: @autoclosure @Sendable () -> StandardOutputEvent) {
                events.withValue {
                    $0.append(event())
                }
            }
        }

        private struct StandardOutputEvent: Equatable, Sendable {
            let type: StandardPipelineType
            let content: String
        }

        private struct StandardPipeline: StandardPipelining {
            let type: StandardPipelineType
            let eventsRecorder: StandardPipelineEventsRecorder

            public func write(content: String) {
                eventsRecorder.events.withValue {
                    $0.append(.init(
                        type: type,
                        content: content.removingAllStyles().trimmingSuffix(in: .whitespacesAndNewlines)
                    ))
                }
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
