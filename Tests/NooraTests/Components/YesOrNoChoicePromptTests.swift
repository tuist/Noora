import Mockable
import Testing

@testable import Noora

struct YesOrNoChoicePromptTests {
    var subject: YesOrNoChoicePrompt!
    var keyStrokeListener = MockKeyStrokeListening()
    var renderer = MockRendering()
    var terminal = MockTerminaling()

    @Test func renders_the_right_content() throws {
        // Given
        let subject = YesOrNoChoicePrompt(
            title: "Authentication",
            question: "Would you like to authenticate?",
            defaultAnswer: true,
            collapseOnSelection: true,
            theme: NooraTheme.test(),
            terminal: terminal,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener
        )

        given(terminal).inRawMode(.any).willProduce { try? $0() }
        given(terminal).isColored.willReturn(false)
        given(renderer).render(.any, standardPipeline: .any).willReturn()
        var onKeyPress: ((KeyStroke) -> OnKeyPressResult)!
        given(keyStrokeListener).listen(terminal: .any, onKeyPress: .any).willReturn()
        when(keyStrokeListener).listen(terminal: .any, onKeyPress: .matching { callback in
            onKeyPress = callback
            return true
        }).perform {
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
