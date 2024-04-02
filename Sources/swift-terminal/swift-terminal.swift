import Foundation
import SwiftTerminal
import Combine

@main
struct CLI {
    static func main() async throws {  
        TerminalErrorMessage.render(message: "The file Project.swift failed to compile", context: "We were trying to compile the file at path /path/to/Project.swift to construct your project graph", nextSteps: [
            "Ensure that the file is present",
            "Ensure that the content of the file is valid"
        ])
//        try await TerminalCollapsibleTitledStream.render(title: "Task 1", stream: makeStream())
//        try await TerminalCollapsibleTitledStream.render(title: "Task 2", stream: makeStream())
//        try await TerminalCollapsibleTitledStream.render(title: "Task 3", stream: makeStream())
//        try await TerminalCollapsibleTitledStream.render(title: "Task 4", stream: makeStream())

    }
    
    private static func makeStream() -> AsyncThrowingStream<TerminalCollapsibleTitledStream.Event, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                for index in 0...5 {
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
}
