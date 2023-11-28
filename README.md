# TerminalUI ⭐️

Command line interfaces (CLIs),
although limited in what can be achieved graphically due to terminal capabilities,
can benefit from having **well-designed and consistent aesthetics** throughout the various commands.
This is a role that **design systems** have traditionally played in other GUIs,
and that is rather an unexplore concept in the context of terminals.

[Tuist](https://tuist.io) terminal experiences suffered for a long time from not having a design system: inconsistent spacing, information competing for attention, hard-to-parse output... And this motivated us to build TerminalUI, a design system for Swift-powered CLIs.

**TerminalUI** builds upon [SwiftTUI](https://github.com/rensbreur/SwiftTUI) to provide a set aesthetically-pleasing, themable, and consistent UI components for building terminal experiences. It codifies years of experience building the Tuist CLI, and we'd love to offer it as a gift to the Swift community to build terminal experiences that are a joy to use.

## Development

### Using Tuist

1. Clone the repository: `git clone https://github.com/tuist/TerminalUI.git`
2. Fetch dependencies: `tuist fetch`
3. Generate the project: `tuist generate`


### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/TerminalUI.git`
2. Open the `Package.swift` with Xcode