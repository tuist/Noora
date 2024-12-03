import Rainbow

extension String {
    /// It returns the given string colored with the given hex value if the provided terminal has colors enabled.
    /// Otherwise, it returns the same string.
    /// - Parameters:
    ///   - hex: A hex value.
    ///   - terminal: A terminal instance.
    /// - Returns: A colored string if the terminal has colors enabled. Otherwise, it returns the same string.
    func hexIfColoredTerminal(_ hex: String, terminal: Terminaling) -> String {
        if terminal.isColored {
            return self.hex(hex)
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
