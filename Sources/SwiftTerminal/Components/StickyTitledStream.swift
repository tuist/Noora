import Foundation
import Rainbow

public enum StickyTitledStreamEvent {
    case output(String)
    case error(String)
    
    var lines: [Substring] {
        switch self {
        case let .error(content): return content.split(separator: "\n")
        case let .output(content): return content.split(separator: "\n")
        }
    }
}

public struct StickyTitledStream<T: AsyncSequence>: Component where T.Element == StickyTitledStreamEvent  {
    
    let title: String
    let stream: T
    
    public init(title: String, stream: T) {
        self.title = title
        self.stream = stream
    }
    
    public func render(renderer: Rendering) async throws {
        var lines: Stack<Substring> = Stack(maximumCapacity: 3)
        for _ in 1...3 {
            lines.push("")
        }
        
        for try await event in stream {
            event.lines.forEach({ lines.push($0) })
            
            try await renderer.render("""
              \(String(lines[2]!).dim)\n
              \(String(lines[1]!).dim)\n
              \(String(lines[0]!).dim)\n
            \("Running: ".green.bold) \(title)
            """)
        }
        
        try await renderer.render("\("Completed: ".green.bold) \(title)")
    }
}
