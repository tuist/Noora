import CombineX
import CXFoundation
import Foundation

class Spinner {
    private(set) var count: Int = 0
    private(set) var cancellables: Set<CombineX.AnyCancellable> = Set()
    private static let frames = [
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
    ]

    init(_ block: @escaping (String) async -> Void) async {
        await block(Spinner.frames[0])
        Timer.CX.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await block(Spinner.frames[self.count % Spinner.frames.count])
                    self.count += 1
                }
            }
            .store(in: &cancellables)
    }
}
