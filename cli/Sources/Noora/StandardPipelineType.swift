public enum StandardPipelineType: CustomStringConvertible, Sendable {
    public var description: String {
        switch self {
        case .error: "stderr"
        case .output: "stdout"
        }
    }

    case output
    case error
}
