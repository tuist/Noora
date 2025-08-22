---
title: "Noora"
titleTemplate: ":title · Tuist"
---

# What is Noora

After years of building a CLI in Swift—[Tuist](https://github.com/tuist/tuist)—and observing utility ecosystems in other programming languages (e.g., [Charm](https://github.com/charmbracelet)), we realized the Swift ecosystem lacked foundational utilities to elevate CLI experiences.

**Noora** is our response.
It distills common CLI patterns into a cohesive design system of themable components, enabling richer and more interactive experiences. While the project is still a work in progress, we plan to continually expand it by identifying and extracting patterns from our work on Tuist.

The [project](https://github.com/tuist/tuist) is open source, licensed under MIT, and we warmly welcome community contributions.

## Get started

First of all, you'll have to add Nora as a package dependency of your project:

```swift
import PackageDescription

let package = Package(
    name: "Noora",
    platforms: [.macOS("12.0")],
    products: [
     /** Your products **/
    ],
    dependencies: [
      .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0")),
    ],
    targets: [
      /** Your targets **/
    ]
)
```

Then you can start using Noora. The interface is simple and intuitive.
You need to create an instance of `Noora`, and every component available is represented as a function in the `Noora` instance.

```swift
Noora().yesOrNoChoicePrompt(
  title: "Authentication",
  question: "Would you like to authenticate?",
  defaultAnswer: true,
  description: "Authentication is required to use some CLI features."
)
```

> [!TIP] Testing
> Noora conforms to the `Noorable` protocol, which we recommend your business logic to depend on. This way, you can easily mock the components and test your business logic without having to interact with the terminal.

## Themes

Components are themable. When creating an instance of `Noora`, you can pass a theme that will be used to render the components. When no theme is passed, it defaults to `Theme.default`:

```swift
let noora = Noora(theme: Theme( // Your custom theme
    primary: "A378F2",
    secondary: "FF8EC6",
    muted: "505050",
    accent: "FFFC67",
    danger: "FF2929",
    success: "89F94F"
))
```

## Localization

Noora lets you customize every built-in text through its `Locales` struct. By default, `Locales.default` contains standard alert titles, prompt instructions, and more, but you can provide your own:

```swift
let customLocales = Locales(
    errorAlertTitle: "❗️ Fehler",
    errorAlertRecommendedTitle: "So beheben Sie den Fehler...",
    warningAlertTitle: "⚠️ Warnung",
    warningAlertRecommendedTitle: "Bitte überprüfen Sie Folgendes:",
    successAlertTitle: "✅ Erfolg",
    successAlertRecommendedTitle: "Ergebnisse",
    infoAlertTitle: "🔎 Info",
    infoAlertRecommendedTitle: "Zusammenfassung",
    choicePromptFilterTitle: "Filtern",
    choicePromptInstructionWithoutFilter: "↑/↓ wählen • Enter bestätigen",
    choicePromptInstructionWithFilter: "↑/↓ wählen • / filtern • Enter bestätigen",
    choicePromptInstructionIsFiltering: "↑/↓ wählen • Esc löschen • Enter bestätigen",
    textPromptValidationErrorsTitle: "Validierungsfehler",
    yesOrNoChoicePromptInstruction: "←/→ wählen • Enter bestätigen",
    yesOrNoChoicePromptPositiveText: YesNoAnswerLocales(fullText: "Ja", character: "j"),
    yesOrNoChoicePromptNegativeText: YesNoAnswerLocales(fullText: "Nein", character: "n")
)
let noora = Noora(locales: customLocales)
```
