import Foundation
import SwiftTerminal

@main
struct CLI {
    static func main() async throws {
        try await StickyTitledStream(title: "xcodebuild -project Foo -scheme foo", stream: stream()).render()
        try await StickyTitledStream(title: "xcodebuild -project Bar -scheme bar", stream: stream()).render()
    }
    
    private static func stream() -> AsyncStream<StickyTitledStreamEvent> {
        return AsyncStream { continuation in
            Task {
                for index in 0...5 {
                    continuation.yield(.output("This is an output from the command \(index)"))

                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    // Check if the AsyncStream was cancelled to stop the loop
                    if Task.isCancelled {
                        continuation.finish()
                        break
                    }
                }
                continuation.finish()
            }
        }
    }
}
