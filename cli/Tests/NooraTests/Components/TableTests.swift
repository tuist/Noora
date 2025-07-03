
import Testing
@testable import Noora

struct TableTests {
    @Test func renders_the_right_output() throws {
        // Given
        let standardOutput = MockStandardPipeline()
        let standardPipelines = StandardPipelines(output: standardOutput)
        let noora = Noora(standardPipelines: standardPipelines)

        let expectation = """
+----------+----------+
| Header 1 | Header 2 |
+----------+----------+
| Row1Col1 | Row1Col2 |
| Row2Col1 | Row2Col2 |
+----------+----------+
"""

        // When
        noora.table(headers: ["Header 1", "Header 2"], rows: [["Row1Col1", "Row1Col2"], ["Row2Col1", "Row2Col2"]])

        // Then
        #expect(standardOutput.writtenContent == expectation)
    }
}
