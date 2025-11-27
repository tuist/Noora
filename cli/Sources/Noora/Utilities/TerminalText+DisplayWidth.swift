extension TerminalText {
    public var displayWidth: Int {
        plain().displayWidth
    }
}

extension Character {
    /// The approximate display width for a character in a terminal.
    ///
    /// There is no standard for this, but it seems like most terminals treat
    /// emojis and ideographs as double width.
    public var displayWidth: Int {
        if unicodeScalars.contains(where: \.properties.isEmojiPresentation) {
            return 2
        } else if unicodeScalars.contains(where: \.properties.isIdeographic) {
            return 2
        } else {
            return 1
        }
    }
}

extension Substring {
    public var displayWidth: Int {
        reduce(into: 0) { $0 += $1.displayWidth }
    }
}

extension String {
    public var displayWidth: Int {
        reduce(into: 0) { $0 += $1.displayWidth }
    }

    /// Truncates to a target display width without splitting scalars.
    func truncated(toDisplayWidth targetWidth: Int) -> String {
        guard targetWidth > 0 else { return "" }

        var collected = ""
        var currentWidth = 0

        for character in self {
            let width = character.displayWidth
            if currentWidth + width > targetWidth {
                break
            }
            currentWidth += width
            collected.append(character)
        }

        return collected
    }
}
