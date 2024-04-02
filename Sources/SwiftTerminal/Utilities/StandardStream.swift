import Foundation
#if os(Linux)
    import Glibc
#endif
#if os(macOS)
    import Foundation
#endif

public struct StandardStreams {
    let output: StandardOutputStreaming
    let error: StandardOutputStreaming
    
    public init(output: StandardOutputStreaming = StandardOutputStream.output, error: StandardOutputStreaming = StandardOutputStream.error) {
        self.output = output
        self.error = error
    }
}

public protocol StandardOutputStreaming {
    func write(content: String)
}

#if MOCKING
    class MockStandardOutputStreaming: StandardOutputStreaming {
        var written: [String] = []

        func write(content: String) {
            written.append(content)
        }
    }
#endif

public enum StandardOutputStream: StandardOutputStreaming {
    case output
    case error

    public func write(content: String) {
        #if os(Linux)
            switch self {
            case .error:
                fputs(content, stderr)
            case .output:
                print(content)
            }
        #endif

        #if os(macOS)
            switch self {
            case .error:
                if let data = content.data(using: .utf8) {
                    try! FileHandle.standardError.write(contentsOf: data)
                }
            case .output:
                if let data = content.data(using: .utf8) {
                    try! FileHandle.standardOutput.write(contentsOf: data)
                }
            }
        #endif
    }
}
