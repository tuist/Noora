import SwiftUI

struct ErrorBox {
    let message: String
    let suggestions: [String]
    
    init(message: String, suggestions: [String]) {
        self.message = message
        self.suggestions = suggestions
    }
}
