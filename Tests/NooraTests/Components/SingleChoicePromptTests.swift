import Mockable
import Testing

@testable import Noora

struct SingleChoicePromptTests {
    enum Option: String, CaseIterable, CustomStringConvertible, Equatable {
        case option1
        case option2
        case option3

        var description: String {
            rawValue
        }
    }

    var subject: SingleChoicePrompt<Option>!
    var keyStrokeListener = MockKeyStrokeListening()
    var renderer = MockRendering()
    var terminal = MockTerminaling()

    @Test func renders_the_right_content() throws {
        // Given
        let subject = SingleChoicePrompt(
            title: "Integration",
            question: "How would you like to integrate Tuist?",
            description: "Decide how the integration should be with your project",
            options: Option.self,
            theme: NooraTheme.test(),
            terminal: terminal,
            renderer: renderer,
            keyStrokeListener: keyStrokeListener
        )
        var inRawMode: (() throws -> Void)!
        given(terminal).inRawMode(.any).willReturn()
        when(terminal).inRawMode(.matching { callback in
            inRawMode = callback
            return true
        }).perform {
            try? inRawMode()
        }

        given(terminal).isColored.willReturn(true)
        given(renderer).render(.any, standardPipeline: .any).willReturn()
        var onKeyPress: ((KeyStroke) -> OnKeyPressResult)!
        given(keyStrokeListener).listen(terminal: .any, onKeyPress: .any).willReturn()
        when(keyStrokeListener).listen(terminal: .any, onKeyPress: .matching { callback in
            onKeyPress = callback
            return true
        }).perform {
            _ = onKeyPress(.downArrowKey)
            _ = onKeyPress(.upArrowKey)
        }

        // When
        _ = subject.run()

        // Then
        verify(renderer).render(.value("""
        Integration
          How would you like to integrate Tuist?
          Decide how the integration should be with your project
           ❯ option1
             option2
             option3
          ↑/↓/k/j up/down • enter confirm
        """), standardPipeline: .any).called(2)
        verify(renderer).render(.value("""
        Integration
          How would you like to integrate Tuist?
          Decide how the integration should be with your project
             option1
           ❯ option2
             option3
          ↑/↓/k/j up/down • enter confirm
        """), standardPipeline: .any).called(1)
        verify(renderer).render(.value("""
        Integration: option1
        """), standardPipeline: .any).called(1)
    }
}
