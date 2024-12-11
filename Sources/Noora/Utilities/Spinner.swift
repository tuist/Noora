import Foundation

class Spinner {

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
    private var isSpinning = true
    private var timer: Timer?

    func spin(_ block: @escaping (String) -> Void) {
        isSpinning = true

        DispatchQueue.global(qos: .userInitiated).async {
            let runLoop = RunLoop.current
            var index = 0

            // Schedule the timer in the current run loop
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if self.isSpinning {
                    block(Spinner.frames[index])
                    index = (index + 1) % Spinner.frames.count
                } else {
                    self.timer?.invalidate()
                }
            }

            // Start the run loop to allow the timer to fire
            while self.isSpinning && runLoop.run(mode: .default, before: .distantFuture) {}
        }
    }

    func stop() {
        isSpinning = false
        timer?.invalidate()
        timer = nil
    }
}
