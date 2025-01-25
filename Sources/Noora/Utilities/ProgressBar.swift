import Foundation

protocol ProgressBar {
    func startProgress(total: Int, interval: TimeInterval?, block: @escaping (String, Int) -> Void)
    func stop()
}
final class DefaultProgressBar: ProgressBar {
    private static let complete = "█"
    private static let incomplete = "▒"
    private static let width = 30
    
    private var isLoading = true
    private var timer: Timer?
    private var completed = 0
    private var progressPercent = 0
    
    func startProgress(total: Int, interval: TimeInterval? , block: @escaping (String, Int) -> Void) {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let runLoop = RunLoop.current
            var index = 1
            
            // Schedule the timer in the current run loop
            self.timer = Timer.scheduledTimer(withTimeInterval: interval ?? 0.05, repeats: true) { _ in
                if index <= total {
                    self.update(total, index)
                    let completedBar = String(repeating: DefaultProgressBar.complete, count: self.completed)
                    let incompleteBar = String(repeating: DefaultProgressBar.incomplete, count: DefaultProgressBar.width - self.completed)
                    block(completedBar+incompleteBar, self.progressPercent)
                    index += 1
                } else {
                    self.timer?.invalidate()
                }
            }
            
            // Start the run loop to allow the timer to fire
            while self.isLoading, runLoop.run(mode: .default, before: .distantFuture) {}
        }
    }
    
    private func update(_ total: Int, _ index: Int) {
        let percentage = Double(index) / Double(total)
        completed = Int(percentage * Double(DefaultProgressBar.width))
        progressPercent = Int(percentage * 100)
    }
    
    func stop() {
        isLoading = false
        timer?.invalidate()
        timer = nil
    }
}
