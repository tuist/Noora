import Rainbow

extension String {
    /// It returns the given string colored with the given hex value if the provided terminal has colors enabled.
    /// Otherwise, it returns the same string.
    /// - Parameters:
    ///   - hex: A hex value.
    ///   - terminal: A terminal instance.
    /// - Returns: A colored string if the terminal has colors enabled. Otherwise, it returns the same string.
    func hexIfColoredTerminal(_ color: String, _ terminal: Terminaling) -> String {
        if terminal.isColored {
            return hex(color)
        } else {
            return self
        }
    }

    /// It returns the given string with the given background hex color if the provided terminal has colors enabled.
    /// Otherwise, it returns the same string.
    /// - Parameters:
    ///   - hex: A hex value.
    ///   - terminal: A terminal instance.
    /// - Returns: A colored string if the terminal has colors enabled. Otherwise, it returns the same string.
    func onHexIfColoredTerminal(_ color: String, _ terminal: Terminaling) -> String {
        if terminal.isColored {
            return onHex(color)
        } else {
            return self
        }
    }

    /// It returns the given string bolded if the provided terminal has colors enabled.
    /// - Parameter terminal: A terminal instance.
    /// - Returns: A bolded string if the terminal has colors enabled. Otherwise, it returns the same string.
    func boldIfColoredTerminal(_ terminal: Terminaling) -> String {
        if terminal.isColored {
            return bold
        } else {
            return self
        }
    }
}
