import Foundation

struct SingleChoicePrompt<T> {
    let question: String
    let options: [T]
    let theme: NooraTheme
    let environment: NooraEnvironment
    
    /**
     TODO
        - Define a protocol T must conform to (if any).
        - Render the options and implement the selection behavior.
     */

    func run() -> T {
        "" as! T
    }
}
