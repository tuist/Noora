import Foundation

public class YesNoPrompt {
    public static func render(question: String, theme: Theme, standardPipelines: StandardPipelines = StandardPipelines()) async -> Bool {
        await standardPipelines.output.write(content: "\(question) (y/n): ")
        let file = FileHandle.standardInput
        var character: String? = nil
        
        while character == nil {
            let data = file.availableData
            if !data.isEmpty {
                character = String(bytes: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
                
        return character == "y"
    }
}
    
