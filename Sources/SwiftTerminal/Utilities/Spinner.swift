import CombineX
import CXFoundation
import Foundation

enum Spinner {
    typealias Cancellable = () -> Void

    actor Counter {
        var count: Int = 0

        func increase() {
            count = count + 1
        }
    }

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

    static func spin(_ block: @escaping (String) async -> Void) async -> Cancellable {
        let counter = Counter()
        await block(Spinner.frames[0])

        let cancellable = Timer.CX.TimerPublisher(interval: 0.1, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await block(Spinner.frames[await counter.count % Spinner.frames.count])
                    await counter.increase()
                }
            }
        return {
            cancellable.cancel()
        }
    }
}
