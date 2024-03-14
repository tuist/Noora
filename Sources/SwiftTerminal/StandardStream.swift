import Foundation
#if os(Linux)
    import Glibc
#endif
#if os(macOS)
    import Foundation
#endif

public protocol StandardOutputStreaming {
    func write(content: String) throws
}

#if MOCKING
    class MockStandardOutputStreaming: StandardOutputStreaming {
        var written: [String] = []

        func write(content: String) throws {
            written.append(content)
        }
    }
#endif

enum StandardOutputStream: StandardOutputStreaming {
    case output
    case error

    func write(content: String) throws {
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
                    try FileHandle.standardError.write(contentsOf: data)
                }
            case .output:
                if let data = content.data(using: .utf8) {
                    try FileHandle.standardOutput.write(contentsOf: data)
                }
            }
        #endif
    }
}
