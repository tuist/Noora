import Foundation

protocol ProgressBarStatus {
    var percentage: UInt { get }
}

struct ProgressBar<T: ProgressBarStatus, E: Error>: Renderable {
    private let stream: AsyncThrowingStream<T, E>

    init(stream: AsyncThrowingStream<T, E>) {
        self.stream = stream
    }

    func render(renderer _: Renderer) {
        // TODO:
    }
}
