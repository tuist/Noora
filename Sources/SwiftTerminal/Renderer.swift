import Foundation

protocol Rendering {
    func render(content: String)
}

struct Renderer: Rendering {
    var lastRenderedContent: [String]

    func render(content _: String) {}
}
