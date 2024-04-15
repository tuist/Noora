import Foundation

public enum YesOrNoPrompt {
    public static func render(
        question: String,
        theme _: Theme,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async -> Bool {
        await standardPipelines.output.write(content: "\(question) (y/n): ")
        let file = FileHandle.standardInput
        var character: String?

        while character == nil {
            let data = file.availableData
            if !data.isEmpty {
                character = String(bytes: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return character == "y"
    }
}
