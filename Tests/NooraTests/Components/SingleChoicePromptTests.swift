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

    let keyStrokeListener = MockKeyStrokeListening()
    let renderer = MockRendering()
    let terminal = MockTerminaling()

    @Test func renders_the_right_content() throws {
        // Given
        let subject = SingleChoicePrompt(
            title: "Integration",
            question: "How would you like to integrate Tuist?",
            description: "Decide how the integration should be with your project",
            options: Option.self,
            theme: NooraTheme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener
        )
        given(terminal).inRawMode(.any).willProduce { try? $0() }

        given(terminal).isInteractive.willReturn(true)
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
