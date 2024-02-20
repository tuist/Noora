import Foundation
#if os(Linux)
    import Glibc
#endif
#if os(macOS)
    import Foundation
#endif

protocol StandardOutputStreaming {
    func write(content: String) throws
}

enum StandardOutputStream: StandardOutputStreaming {
    case output
    case error

    func write(content: String) throws {
        #if os(Linux)
            switch self {
            case .error:
                write(FileDescriptor.standardError, content, content.utf8.count)
            case .output:
                write(FileDescriptor.standardError, content, content.utf8.count)
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
