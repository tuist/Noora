import os

class MockLogger: Logger {
    let logs = [String]()
    
    func info(message: String) {
        logs.append(message)
    }
    
    func trace(message: String) {
        logs.append(message)
    }
    
    func notice(message: String) {
        logs.append(message)
    }
    
    func error(message: String) {
        logs.append(message)
    }
}
