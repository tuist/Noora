import ArgumentParser
import Foundation
import Noora

struct InfoCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "info", abstract: "Shows an info alert.")
    }

    @Option(
        name: .shortAndLong,
        help: "The message to show in the info alert."
    )
    var message: String

    @Option(
        name: .shortAndLong,
        help: "Takeaways to show in the info alert."
    )
    var takeaway: [String] = []

    func run() async throws {
        let noora = Noora()
        if takeaway.isEmpty {
            noora.info(InfoAlert(stringLiteral: message))
        } else {
            noora.info(InfoAlert.alert(TerminalText(stringLiteral: message), takeaways: takeaway.map { TerminalText(stringLiteral: $0) }))
        }
    }
}
