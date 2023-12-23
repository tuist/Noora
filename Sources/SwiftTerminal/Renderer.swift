import Foundation

protocol Renderable {
    func render(renderer: Renderer)
}

public protocol Renderer {}
