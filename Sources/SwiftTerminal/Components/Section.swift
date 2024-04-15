import Foundation

public enum Section {
    public static func render(title: String, theme: Theme, streams: StandardPipelines = StandardPipelines()) async {
        await streams.output.write(content: "\(title.hex(theme.primary).bold)")
    }
}
