import Foundation

enum Spinner {
    typealias Cancellable = () -> Void

    actor Counter {
        var count: Int = 0

        func increase() {
            count += 1
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

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: 0.1)
        timer.setEventHandler {
            Task {
                await block(Spinner.frames[await counter.count % Spinner.frames.count])
                await counter.increase()
            }
        }
        timer.resume()

        return {
            timer.cancel()
        }
    }
}
