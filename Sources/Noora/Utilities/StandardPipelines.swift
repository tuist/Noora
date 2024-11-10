import Foundation
#if os(Linux)
    import Glibc
#endif
#if os(macOS)
    import Foundation
#endif

public protocol StandardPipelining {
    func write(content: String)
}

public struct StandardOutputPipeline: StandardPipelining {
    public init() {}

    public func write(content: String) {
        print(content, terminator: "")
    }
}

public struct StandardErrorPipeline: StandardPipelining {
    public init() {}

    public func write(content: String) {
        #if os(Linux)
            fputs(content, stderr)
        #endif

        #if os(macOS)
            if let data = content.data(using: .utf8) {
                // swiftlint:disable:next force_try
                try! FileHandle.standardError.write(contentsOf: data)
            }
        #endif
    }
}

public struct StandardPipelines {
    public let output: StandardPipelining
    public let error: StandardPipelining

    public init(output: StandardPipelining = StandardOutputPipeline(), error: StandardPipelining = StandardErrorPipeline()) {
        self.output = output
        self.error = error
    }
}
