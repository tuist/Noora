import Noora

class MockStandardPipeline: StandardPipelining {
    var writtenContent: String = ""

    func write(content: String) {
        writtenContent.append(content)
    }
}
