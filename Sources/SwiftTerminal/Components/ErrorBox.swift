import Foundation

struct ErrorBox: Renderable {
    let message: String
    let suggestions: [String]

    func render(renderer _: Renderer) {}
}
