import ArgumentParser
import Foundation
import Noora

struct TableCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "table", abstract: "Prints a table.")
    }

    @Option(name: .customLong("headers"), help: "Comma-separated list of headers.")
    var headers: String

    @Option(name: .customLong("rows"), help: "Comma-separated list of rows, where each row is also comma-separated.")
    var rows: String

    func run() async throws {
        let noora = Noora()
        let parsedHeaders = headers.components(separatedBy: ",")
        let parsedRows = rows.components(separatedBy: ";").map { $0.components(separatedBy: ",") }
        noora.table(headers: parsedHeaders, rows: parsedRows)
    }
}
