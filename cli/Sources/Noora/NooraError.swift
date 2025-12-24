import Foundation

// MARK: - Error Types

public enum NooraError: LocalizedError {
    case nonInteractiveTerminal
    case invalidTableData
    case emptyTable
    case userCancelled

    public var errorDescription: String? {
        switch self {
        case .nonInteractiveTerminal:
            return "Rendering an interactive component in a non-interactive terminal session is not allowed."
        case .invalidTableData:
            return "The provided table data is invalid. Ensure all rows match the number of columns provided."
        case .emptyTable:
            return "The provided table data is empty."
        case .userCancelled:
            return "The user cancelled the operation."
        }
    }
}
