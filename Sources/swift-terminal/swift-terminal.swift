import Foundation
import Rainbow
import SwiftTerminal

@main
enum CLI {
    static func main() async throws {
        let tuistTheme = Theme(primary: "A378F2", secondary: "FF8EC6", accent: "FFFC67", danger: "FF2929", success: "89F94F")
        let standardPipelines = StandardPipelines()

//        await standardPipelines.output.write(content: "---- Yes/No response ----\n".bold)
//        let result = await YesOrNoPrompt.render(question: "Would you like to continue?", theme: tuistTheme)

//        await standardPipelines.output.write(content: "----- Table -----\n".bold)
//        await Table.render(rows: [
//            ["Framework", "Size", "Type", "Hash", "Compilation time"],
//            ["TuistCore", "25 Mb", "Dynamic framework", "AB1252CD1252110000BCD", "1 min"],
//            ["TuistSupport", "26 Mb", "Dynamic framework", "AB1252CD1252110000BCD", "2 min"],
//            ["TuistGenerator", "2 Mb", "Static library", "AB1252CD1252110000BCD", "2 min"]
//
//        ], theme: tuistTheme, standardPipelines: standardPipelines)
//
//        await standardPipelines.output.write(content: "\n\n----- CompletionMessage(.error) -----\n".bold)
//
//        await CompletionMessage.render(message: .error(message: "The file Project.swift failed to compile",
//                                                       context: "We were trying to compile the file at path /path/to/Project.swift to construct your project graph", nextSteps: [
//            "Ensure that the file is present",
//        ]), theme: tuistTheme, standardPipelines: standardPipelines)
//
//        await standardPipelines.output.write(content: "\n\n----- CompletionMessage(.success) -----\n".bold)
//        await CompletionMessage.render(message: .success(action: "Project generation"), theme: tuistTheme, standardPipelines:
//        standardPipelines)
//
//        await standardPipelines.output.write(content: "\n\n----- CompletionMessage(.warnings) -----\n".bold)
//        await CompletionMessage.render(message: .warnings(["Your hosted version of Tuist Cloud is outdated", "We detected
//        invalid binaries in the cache"]), theme: tuistTheme, standardPipelines: standardPipelines)
//
//        await standardPipelines.output.write(content: "\n\n----- CollapsibleStream -----\n".bold)
//        try await CollapsibleStream.render(
//            title: "xcodebuild -scheme 1 -workspace Tuist.xcworkspace",
//            stream: makeStream(),
//            theme: tuistTheme
//        )
//        try await CollapsibleStream.render(title: "xcodebuild -scheme 2 -workspace Tuist.xcworkspace", stream: makeStream(),
//        theme: tuistTheme)
//        try await CollapsibleStream.render(title: "xcodebuild -scheme 3 -workspace Tuist.xcworkspace", stream: makeStream(),
//        theme: tuistTheme)
//        try await CollapsibleStream.render(title: "xcodebuild -scheme 4 -workspace Tuist.xcworkspace", stream: makeStream(),
//        theme: tuistTheme)
        try await TerminalConcurrentAsyncStreams.render(
            title: "Uploading frameworks to Tuist Cloud",
            completionMessage:
            "Completed uploading",
            theme: tuistTheme,
            asyncStreams: [
                "FrameworkA": makeProgressStream(),
                "FrameworkB": makeProgressStream(),
                "FrameworkC": makeProgressStream(),
                "FrameworkD": makeProgressStream(),
                "FrameworkE": makeProgressStream(),
                "FrameworkF": makeProgressStream(),
            ]
        )
//
//        print("\n\n")
//

//
//        print("\n\n")

//        try await TerminalCollapsibleTitledStream.renderSectioned(section: "Building XCFrameworks", renderables: [
//            (title: "xcodebuild -scheme 1 -workspace Tuist.xcworkspace", stream: makeStream()),
//            (title: "xcodebuild -scheme 2 -workspace Tuist.xcworkspace", stream: makeStream()),
//            (title: "xcodebuild -scheme 3 -workspace Tuist.xcworkspace", stream: makeStream()),
//            (title: "xcodebuild -scheme 4 -workspace Tuist.xcworkspace", stream: makeStream()),
//        ], theme: tuistTheme)
    }

    private static func makeStream() -> AsyncThrowingStream<CollapsibleStream.Event, Error> {
        AsyncThrowingStream { continuation in
            Task {
                for index in 0 ... 5 {
                    continuation.yield(.output("This is an output from the command \(index)"))
                    if #available(macOS 13.0, *) {
                        try await Task.sleep(for: .seconds(0.5))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                continuation.finish()
            }
        }
    }

    private static func makeProgressStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { continuation in
            Task {
                for progress in 0 ... 100 {
                    continuation.yield(progress)
                    if #available(macOS 13.0, *) {
                        let random = Double(Int.random(in: 0 ... 100)) / 100.0

                        try await Task.sleep(for: .seconds(0.5) * random)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                continuation.finish()
            }
        }
    }
}
