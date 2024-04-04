import Foundation
import Combine

class Spinner {
    private(set) var count: Int = 0
    private(set) var cancellables: Set<AnyCancellable> = Set()
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
        "⠏"
    ]
    
    init(_ block: @escaping (String) async -> Void) {
//        block(Spinner.frames[0])
//        Timer.publish(every: 0.1, on: .main, in: .common)
//            .autoconnect()
//            .sink() { [weak self] _ in
//                guard let self = self else { return }
//                block(Spinner.frames[self.count % Spinner.frames.count])
//                self.count += 1
//            }.store(in: &cancellables)
    }
}
