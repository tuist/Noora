import Foundation

public enum Section {
    public static func render(title: String, theme: NooraTheme, streams: StandardPipelines = StandardPipelines()) async {
        await streams.output.write(content: "\(title.hex(theme.primary).bold)")
    }
}
