import Foundation

public enum TerminalConcurrentAsyncStreams {
    actor Progress {
        var streams: [String: Int] = [:]

        func update(forStream streamId: String, progress: Int) {
            streams[streamId] = progress
        }

        func progress(forStream streamId: String) -> Int {
            streams[streamId]!
        }
    }

    public static func render(
        title: String,
        completionMessage: String,
        theme: Theme,
        asyncStreams: [String: AsyncThrowingStream<Int, Error>],
        streams: StandardPipelines = StandardPipelines()
    ) async throws {
        if isTerminalInteractive() {
            try await renderInteractive(
                title: title,
                completionMessage: completionMessage,
                theme: theme,
                asyncStreams: asyncStreams,
                streams: streams
            )
        } else {
            // TODO:
        }
    }

    // swiftlint:disable:next function_body_length
    public static func renderInteractive(
        title: String,
        completionMessage: String,
        theme: Theme,
        asyncStreams: [String: AsyncThrowingStream<Int, Error>],
        streams: StandardPipelines = StandardPipelines()
    ) async throws {
        let renderer = Renderer()
        let jointProgress = Progress()
        let progressCharacters = 20

        let idColumnSize = asyncStreams.keys.reduce(0) { current, next in
            if next.count > current {
                return next.count
            } else {
                return current
            }
        }

        for streamId in asyncStreams.keys {
            await jointProgress.update(forStream: streamId, progress: 0)
        }

        @Sendable func renderProgress() async {
            var inProgressLines: [String] = []
            var completedProcesses: [String] = []

            for streamId in asyncStreams.keys.sorted() {
                let progress = await jointProgress.progress(forStream: streamId)
                if progress == 100 {
                    completedProcesses.append(streamId)
                } else {
                    let filling = (0 ... (idColumnSize - streamId.count)).map { _ in " " }.joined()

                    let filledProgressCharacters = Int(
                        Float(progress) / 100.0 * Float(progressCharacters)
                    )
                    let emptyProgressCharacters = progressCharacters - filledProgressCharacters

                    let progressBar =
                        "\((0 ..< filledProgressCharacters).map { _ in "◼︎" }.joined())\((0 ..< emptyProgressCharacters).map { _ in "-" }.joined())"

                    inProgressLines.append(
                        "  \(streamId.hex(theme.secondary).bold) \(filling) [\(progressBar)]  \(progress)%"
                    )
                }
            }

            let content =
                if !inProgressLines.isEmpty
            {
                """
                \(title.hex(theme.primary).bold)\n \n
                \(inProgressLines.joined(separator: "\n"))
                \(
                    completedProcesses
                        .isEmpty ? "" :
                        " \n\("\(completionMessage):".hex(theme.success).bold) \(completedProcesses.joined(separator: ", "))"
                )
                """
            } else {
                """
                \(
                    completedProcesses
                        .isEmpty ? "" :
                        "\("\(completionMessage):".hex(theme.success).bold) \(completedProcesses.joined(separator: ", "))"
                )
                """
            }
            await renderer.render(content, standardPipeline: streams.output)
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            asyncStreams.forEach { identifier, stream in
                group.addTask {
                    for try await progress in stream {
                        await jointProgress.update(forStream: identifier, progress: progress)
                        await renderProgress()
                    }
                    await jointProgress.update(forStream: identifier, progress: 100)
                }
            }
            try await group.waitForAll()
        }
    }
}
