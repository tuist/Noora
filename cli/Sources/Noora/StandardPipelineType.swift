public enum StandardPipelineType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .error: "stderr"
        case .output: "stdout"
        }
    }

    case output
    case error
}
