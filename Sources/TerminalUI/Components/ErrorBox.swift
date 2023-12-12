import SwiftUI

struct ErrorBox: Renderable {
    let message: String
    let suggestions: [String]
    
    init(message: String, suggestions: [String]) {
        self.message = message
        self.suggestions = suggestions
    }
    
    func render(renderer: Renderer) {
        
    }
}
