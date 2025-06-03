import Noora

class MockRenderer: Rendering {
    var renders: [String] = []

    func render(_ input: String, standardPipeline _: any StandardPipelining) {
        renders.append(input)
    }
}
