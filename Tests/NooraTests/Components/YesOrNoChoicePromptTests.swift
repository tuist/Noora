import Mockable
import Testing

@testable import Noora

struct YesOrNoChoicePromptTests {
    var subject: YesOrNoChoicePrompt!
    let keyStrokeListener = MockKeyStrokeListening()
    let renderer = MockRendering()
    let terminal = MockTerminaling()

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

        given(terminal).isInteractive.willReturn(true)
        given(terminal).inRawMode(.any).willProduce { try? $0() }
        given(terminal).isColored.willReturn(false)
        given(renderer).render(.any, standardPipeline: .any).willReturn()
        given(keyStrokeListener).listen(terminal: .any, onKeyPress: .any).willProduce { _, onKeyPress in
            _ = onKeyPress(.rightArrowKey)
            _ = onKeyPress(.leftArrowKey)
        }

        // When
        _ = subject.run()

        // Then
        verify(renderer).render(.value("""
        Authentication
          Would you like to authenticate? [ Yes (y) ] /  No (n) 
          ←/→/h/l left/right • enter confirm
        """), standardPipeline: .any).called(2)
        verify(renderer).render(.value("""
        Authentication
          Would you like to authenticate?  Yes (y)  / [ No (n) ]
          ←/→/h/l left/right • enter confirm
        """), standardPipeline: .any).called(1)
        verify(renderer).render(.value("""
        Authentication: Yes
        """), standardPipeline: .any).called(1)
    }
}
