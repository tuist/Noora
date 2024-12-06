import Testing

@testable import Noora

struct YesOrNoChoicePromptTests {
    var subject: YesOrNoChoicePrompt!
    let keyStrokeListener = MockKeyStrokeListener()
    let renderer = MockRenderer()
    var terminal = MockTerminal(isColored: false)

    @Test func renders_the_right_content() throws {
        // Given
        let subject = YesOrNoChoicePrompt(
            title: "Authentication",
            question: "Would you like to authenticate?",
            description: nil,
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            defaultAnswer: true
        )
        keyStrokeListener.keyPressStub = [.rightArrowKey, .leftArrowKey]

        // When
        _ = subject.run()

        // Then

        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        Authentication
          Would you like to authenticate? [ Yes (y) ] /  No (n) 
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        Authentication
          Would you like to authenticate?  Yes (y)  / [ No (n) ]
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        Authentication
          Would you like to authenticate? [ Yes (y) ] /  No (n) 
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        Authentication: Yes
        """)
    }
}
