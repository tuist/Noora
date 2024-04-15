import Foundation
#if os(Linux)
    import Glibc
#endif
#if os(macOS)
    import Foundation
#endif

public protocol StandardPipelining: Actor {
    func write(content: String)
}

public actor StandardOutputPipeline: StandardPipelining {
    public init() {}

    public func write(content: String) {
        #if os(Linux)
            print(content)
        #endif

        #if os(macOS)
            if let data = content.data(using: .utf8) {
                try! FileHandle.standardOutput.write(contentsOf: data)
            }
        #endif
    }
}

public actor StandardErrorPipeline: StandardPipelining {
    public init() {}

    public func write(content: String) {
        #if os(Linux)
            fputs(content, stderr)
        #endif

        #if os(macOS)
            if let data = content.data(using: .utf8) {
                try! FileHandle.standardError.write(contentsOf: data)
            }
        #endif
    }
}

public actor StandardPipelines {
    public let output: StandardPipelining
    public let error: StandardPipelining

    public init(output: StandardPipelining = StandardOutputPipeline(), error: StandardPipelining = StandardErrorPipeline()) {
        self.output = output
        self.error = error
    }
}
