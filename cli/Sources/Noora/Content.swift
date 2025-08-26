import Foundation

/// A struct that encapsulates localized alert titles and recommended titles for different types of alerts.
public struct Content {
    /// The default content instance with standard alert titles and recommendations.
    public static var `default` = Content(
        errorAlertTitle: "✖ Error",
        errorAlertRecommendedTitle: "Sorry this didn’t work. Here’s what to try next",
        warningAlertTitle: "! Warning",
        warningAlertRecommendedTitle: "The following items may need attention",
        successAlertTitle: "✔ Success",
        successAlertRecommendedTitle: "Takeaways",
        infoAlertTitle: "i Info",
        infoAlertRecommendedTitle: "Takeaways",
        choicePromptFilterTitle: "Filter",
        choicePromptInstructionWithoutFilter: "↑/↓/k/j up/down • enter confirm",
        choicePromptInstructionWithFilter: "↑/↓/k/j up/down • / filter • enter confirm",
        choicePromptInstructionIsFiltering: "↑/↓ up/down • esc clear filter • enter confirm",
        textPromptValidationErrorsTitle: "Validation errors",
        yesOrNoChoicePromptInstruction: "←/→/h/l left/right • enter confirm",
        yesOrNoChoicePromptPositiveText: YesNoAnswerContent(fullText: "Yes", character: "y"),
        yesOrNoChoicePromptNegativeText: YesNoAnswerContent(fullText: "No", character: "n")
    )

    /// The title to display in error alerts.
    public let errorAlertTitle: String

    /// The recommended title for error alerts.
    public let errorAlertRecommendedTitle: String

    /// The title to display in warning alerts.
    public let warningAlertTitle: String

    /// The recommended title for warning alerts.
    public let warningAlertRecommendedTitle: String

    /// The title to display in success alerts.
    public let successAlertTitle: String

    /// The recommended title for success alerts.
    public let successAlertRecommendedTitle: String

    /// The title to display in informational alerts.
    public let infoAlertTitle: String

    /// The recommended title for informational alerts.
    public let infoAlertRecommendedTitle: String

    /// The title for the filter used in choice prompts.
    public let choicePromptFilterTitle: String

    /// The instruction text for choice prompts when no filter is applied.
    public let choicePromptInstructionWithoutFilter: String

    /// The instruction text for choice prompts when filtering is enabled.
    public let choicePromptInstructionWithFilter: String

    /// The instruction text for choice prompts while filtering is active.
    public let choicePromptInstructionIsFiltering: String

    /// The title to display for validation errors in text prompts.
    public let textPromptValidationErrorsTitle: String

    /// The instruction text for yes/no choice prompts.
    public let yesOrNoChoicePromptInstruction: String

    /// The content for the positive ("Yes") answer option in yes/no choice prompts.
    public let yesOrNoChoicePromptPositiveText: YesNoAnswerContent

    /// The content for the negative ("No") answer option in yes/no choice prompts.
    public let yesOrNoChoicePromptNegativeText: YesNoAnswerContent

    /// Creates a new Content instance with the specified alert titles, recommendations, and prompt localizations.
    ///
    /// - Parameters:
    ///   - errorAlertTitle: The title to display in error alerts.
    ///   - errorAlertRecommendedTitle: The recommended title for error alerts.
    ///   - warningAlertTitle: The title to display in warning alerts.
    ///   - warningAlertRecommendedTitle: The recommended title for warning alerts.
    ///   - successAlertTitle: The title to display in success alerts.
    ///   - successAlertRecommendedTitle: The recommended title for success alerts.
    ///   - infoAlertTitle: The title to display in informational alerts.
    ///   - infoAlertRecommendedTitle: The recommended title for informational alerts.
    ///   - choicePromptFilterTitle: The title for the filter used in choice prompts.
    ///   - choicePromptInstructionWithoutFilter: The instruction text for choice prompts when no filter is applied.
    ///   - choicePromptInstructionWithFilter: The instruction text for choice prompts when filtering is enabled.
    ///   - choicePromptInstructionIsFiltering: The instruction text for choice prompts while filtering is active.
    ///   - textPromptValidationErrorsTitle: The title to display for validation errors in text prompts.
    ///   - yesOrNoChoicePromptInstruction: The instruction text for yes/no choice prompts.
    ///   - yesOrNoChoicePromptPositiveText: The content for the positive answer option.
    ///   - yesOrNoChoicePromptNegativeText: The content for the negative answer option.
    public init(
        errorAlertTitle: String,
        errorAlertRecommendedTitle: String,
        warningAlertTitle: String,
        warningAlertRecommendedTitle: String,
        successAlertTitle: String,
        successAlertRecommendedTitle: String,
        infoAlertTitle: String,
        infoAlertRecommendedTitle: String,
        choicePromptFilterTitle: String,
        choicePromptInstructionWithoutFilter: String,
        choicePromptInstructionWithFilter: String,
        choicePromptInstructionIsFiltering: String,
        textPromptValidationErrorsTitle: String,
        yesOrNoChoicePromptInstruction: String,
        yesOrNoChoicePromptPositiveText: YesNoAnswerContent,
        yesOrNoChoicePromptNegativeText: YesNoAnswerContent
    ) {
        self.errorAlertTitle = errorAlertTitle
        self.errorAlertRecommendedTitle = errorAlertRecommendedTitle
        self.warningAlertTitle = warningAlertTitle
        self.warningAlertRecommendedTitle = warningAlertRecommendedTitle
        self.successAlertTitle = successAlertTitle
        self.successAlertRecommendedTitle = successAlertRecommendedTitle
        self.infoAlertTitle = infoAlertTitle
        self.infoAlertRecommendedTitle = infoAlertRecommendedTitle
        self.choicePromptFilterTitle = choicePromptFilterTitle
        self.choicePromptInstructionWithoutFilter = choicePromptInstructionWithoutFilter
        self.choicePromptInstructionWithFilter = choicePromptInstructionWithFilter
        self.choicePromptInstructionIsFiltering = choicePromptInstructionIsFiltering
        self.textPromptValidationErrorsTitle = textPromptValidationErrorsTitle
        self.yesOrNoChoicePromptInstruction = yesOrNoChoicePromptInstruction
        self.yesOrNoChoicePromptPositiveText = yesOrNoChoicePromptPositiveText
        self.yesOrNoChoicePromptNegativeText = yesOrNoChoicePromptNegativeText
    }
}

/// A struct representing the content for a yes-or-no answer option.
public struct YesNoAnswerContent {
    /// The full-text representation of the answer option.
    public let fullText: String

    /// The single-character shorthand for the answer option.
    public let character: Character

    /// Creates a new YesNoAnswerContent instance.
    ///
    /// - Parameters:
    ///   - fullText: The full-text representation of the answer (e.g., "Yes").
    ///   - character: The single-character shorthand for the answer (e.g., 'y').
    public init(fullText: String, character: Character) {
        self.fullText = fullText
        self.character = character
    }
}
