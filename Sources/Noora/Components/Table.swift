import Foundation

public enum Table {
    public static func render(
        rows: [[String]],
        theme: NooraTheme,
        standardPipelines: StandardPipelines = StandardPipelines()
    ) async {
        let columnSizes = rows.reduce(into: [Int]()) { sizes, row in
            var index = 0
            for item in row {
                if index < sizes.count {
                    sizes[index] = (item.count > sizes[index]) ? item.count : sizes[index]
                } else {
                    sizes.append(item.count)
                }
                index += 1
            }
        }

        var rowIndex = 0
        for row in rows {
            if rowIndex != 0 {
                await standardPipelines.output.write(content: "\n")
            }

            var columnIndex = 0
            for item in row {
                let columnSize = columnSizes[columnIndex]

                var content = "\(item)\((0 ..< (columnSize - item.count)).map { _ in " " }.joined())"

                if rowIndex == 0 {
                    content = content.hex(theme.primary)
                } else if columnIndex == 0 {
                    content = content.hex(theme.secondary)
                }

                await standardPipelines.output.write(content: content)
                await standardPipelines.output.write(content: "   ") // Space between columns

                columnIndex += 1
            }
            rowIndex += 1
        }
        await standardPipelines.output.write(content: "\n")
    }
}
