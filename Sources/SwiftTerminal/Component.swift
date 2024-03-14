import Foundation

public protocol Component {
    func render(renderer: Rendering) async throws
}

public extension Component {
    func render() async throws {
        try await self.render(renderer: Renderer())
    }
}
