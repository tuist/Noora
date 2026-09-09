import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif canImport(Bionic)
    import Bionic
#elseif os(Windows)
    import ucrt
#endif
#if os(macOS)
    import Foundation
#endif

public protocol StandardPipelining: Sendable {
    func write(content: String)
}

public struct StandardOutputPipeline: StandardPipelining {
    public init() {}

    public func write(content: String) {
        print(content, terminator: "")
        // Swift's `print(_:terminator:)` writes through libc's `stdout`,
        // which is block-buffered when the descriptor is not a TTY
        // (typical on CI runners, where stdout is a pipe to the runner
        // agent). Every progress message therefore accumulates in the
        // ~4-8 KB stdio buffer until it fills or the process exits
        // cleanly. When a CI provider cancels the step with `SIGKILL`
        // — for example on a job timeout — the buffer is discarded
        // and the user sees no output at all, even for work that
        // reached the write. Flushing after every write keeps live
        // programmes observable and turns an apparent silent hang into
        // an accurate progress log.
        //
        // On Apple platforms the standard streams behave differently,
        // and existing callers rely on their default buffering, so
        // this only forces a flush where libc's block buffering would
        // otherwise swallow output on a stalled or cancelled process.
        #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(visionOS) && !os(watchOS)
            fflush(stdout)
        #endif
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

public struct StandardPipelines: Sendable {
    public let output: StandardPipelining
    public let error: StandardPipelining

    public init(output: StandardPipelining = StandardOutputPipeline(), error: StandardPipelining = StandardErrorPipeline()) {
        self.output = output
        self.error = error
    }
}
