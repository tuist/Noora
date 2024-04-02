import Foundation
import SwiftTerminal
import Combine

@main
struct CLI {
    static func main() async throws {    
        try await CollapsibleTitledStream(title: "Task 1", stream: makeStream())
        try await CollapsibleTitledStream(title: "Task 2", stream: makeStream())
        try await CollapsibleTitledStream(title: "Task 3", stream: makeStream())
        try await CollapsibleTitledStream(title: "Task 4", stream: makeStream())

    }
    
    private static func makeStream() -> AsyncThrowingStream<CollapsibleTitledStream.Event, Error> {
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
