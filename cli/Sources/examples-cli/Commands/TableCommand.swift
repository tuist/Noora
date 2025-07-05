import ArgumentParser
import Foundation
import Noora

struct TableCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "table",
        abstract: "A command that showcases table components."
    )

    func run() async throws {
        let noora = Noora()

        print("📊 Table Component Examples\n")

        // Example 1: Simple static table
        print("1. Simple static table:")
        await simpleStaticTable(noora)

        print("\n" + String(repeating: "=", count: 50) + "\n")

        // Example 2: Styled table with semantic colors
        print("2. Styled table with semantic colors:")
        await semanticStyledTable(noora)

        print("\n" + String(repeating: "=", count: 50) + "\n")

        // Example 3: Large table with pagination
        print("3. Large table with pagination (use arrow keys to navigate, 'q' to quit):")
        try await paginatedTable(noora)

        print("\n" + String(repeating: "=", count: 50) + "\n")

        // Example 4: Interactive table selection
        print("4. Interactive table for selection:")

        do {
            let selectedIndex = try await interactiveTable(noora)
            print("You selected option at index: \(selectedIndex)")
        } catch {
            print("Selection cancelled or failed: \(error)")
        }
    }

    private func simpleStaticTable(_ noora: Noora) async {
        let headers = ["Name", "Role", "Status"]
        let rows = [
            ["John Doe", "Developer", "Active"],
            ["Jane Smith", "Designer", "Active"],
            ["Bob Wilson", "Manager", "Inactive"],
            ["Alice Brown", "Tester", "Pending"],
        ]

        noora.table(headers: headers, rows: rows)
    }

    private func styledTable(_ noora: Noora) async {
        let headers = ["File", "Size", "Modified", "Type"]
        let rows = [
            ["README.md", "2.4 KB", "2024-01-15", "md"],
            ["Package.swift", "1.8 KB", "2024-01-14", "swift"],
            ["Sources/", "--", "2024-01-16", "dir"],
            ["Tests/", "--", "2024-01-12", "dir"],
            ["Documentation.md", "15.2 KB", "2024-01-10", "md"],
        ]

        noora.table(headers: headers, rows: rows)
    }

    private func paginatedTable(_ noora: Noora) async throws {
        let headers = ["ID", "Task Name", "Priority", "Assignee", "Due Date"]

        // Generate a large dataset
        let priorities = ["High", "Medium", "Low"]
        let assignees = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
        let tasks = [
            "Implement user authentication",
            "Design database schema",
            "Create REST API endpoints",
            "Write unit tests",
            "Update documentation",
            "Fix memory leak issue",
            "Optimize query performance",
            "Add error handling",
            "Implement caching layer",
            "Review code quality",
        ]

        var rows: [[String]] = []
        for i in 1 ... 50 {
            let task = tasks[i % tasks.count]
            let priority = priorities[i % priorities.count]
            let assignee = assignees[i % assignees.count]
            let dueDate = "2024-0\((i % 9) + 1)-\(String(format: "%02d", (i % 28) + 1))"

            rows.append([
                "\(i)",
                task,
                priority,
                assignee,
                dueDate,
            ])
        }

        try noora.paginatedTable(headers: headers, rows: rows, pageSize: 10)
    }

    private func largTablePreview(_ noora: Noora) async {
        print("   [Preview of large table - first 5 rows]")
        let headers = ["ID", "Task Name", "Priority"]

        let rows = [
            ["1", "Implement user authentication", "High"],
            ["2", "Design database schema", "Medium"],
            ["3", "Create REST API endpoints", "Low"],
            ["4", "Write unit tests", "High"],
            ["5", "Update documentation", "Medium"],
        ]

        noora.table(headers: headers, rows: rows)
        print("   ... (45 more rows would be shown with pagination)")
    }

    private func interactiveTable(_ noora: Noora) async throws -> Int {
        let headers = ["Language", "Type", "Year", "Popularity", "Description"]

        let languageData = [
            ("Swift", "Compiled", "2014", "High", "Apple's modern language for iOS/macOS development"),
            ("Python", "Interpreted", "1991", "Very High", "Versatile language for data science and web dev"),
            ("JavaScript", "Interpreted", "1995", "Very High", "Essential for web development and Node.js"),
            ("Rust", "Compiled", "2010", "Growing", "Systems programming with memory safety"),
            ("Go", "Compiled", "2009", "High", "Google's language for cloud and networking"),
            ("TypeScript", "Transpiled", "2012", "High", "JavaScript with static type checking"),
            ("Kotlin", "Compiled", "2011", "Medium", "JetBrains' modern alternative to Java"),
            ("C++", "Compiled", "1985", "High", "Powerful systems and game development language"),
            ("Java", "Compiled", "1995", "Very High", "Enterprise and Android development platform"),
            ("C#", "Compiled", "2000", "High", "Microsoft's versatile .NET language"),
            ("Ruby", "Interpreted", "1995", "Medium", "Elegant language popular for web frameworks"),
            ("PHP", "Interpreted", "1995", "High", "Dominant language for web backend development"),
        ]

        let rows = languageData.map { lang, type, year, popularity, description in
            [lang, type, year, popularity, description]
        }

        return try await noora.interactiveTable(headers: headers, rows: rows, pageSize: 8)
    }

    private func interactiveTablePreview(_ noora: Noora) async {
        print("   [Preview of interactive table - first 5 programming languages]")
        let headers = ["Language", "Type", "Year", "Popularity", "Description"]

        let languageData = [
            ("Swift", "Compiled", "2014", "High", "Apple's modern language for iOS/macOS development"),
            ("Python", "Interpreted", "1991", "Very High", "Versatile language for data science and web dev"),
            ("JavaScript", "Interpreted", "1995", "Very High", "Essential for web development and Node.js"),
            ("Rust", "Compiled", "2010", "Growing", "Systems programming with memory safety"),
            ("Go", "Compiled", "2009", "High", "Google's language for cloud and networking"),
        ]

        let rows = languageData.map { lang, type, year, popularity, description in
            [lang, type, year, popularity, description]
        }

        noora.table(headers: headers, rows: rows)
        print("   (In interactive mode, you could navigate with arrows and press Enter to select)")
    }

    private func semanticStyledTable(_ noora: Noora) async {
        // Example using the new semantic styling API
        let styledHeaders: [TableCellStyle] = [
            .primary("User"),
            .accent("Status"),
            .muted("Score"),
            .secondary("Role"),
        ]

        let styledRows: [StyledTableRow] = [
            [.plain("Alice"), .success("Active"), .plain("95"), .plain("Admin")],
            [.plain("Bob"), .warning("Pending"), .plain("87"), .plain("User")],
            [.plain("Charlie"), .danger("Suspended"), .plain("72"), .plain("Moderator")],
            [.plain("Diana"), .success("Active"), .plain("91"), .plain("User")],
            [.plain("Eve"), .muted("Inactive"), .plain("65"), .plain("Guest")],
        ]

        noora.table(headers: styledHeaders, rows: styledRows)
    }
}
