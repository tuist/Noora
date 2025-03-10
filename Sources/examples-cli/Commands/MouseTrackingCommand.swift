import ArgumentParser
import Foundation
import Noora
import Rainbow

struct MouseTrackingCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mouse-tracking",
        abstract: "A command that showcases mouse tracking in the terminal."
    )

    mutating func run() async throws {
        let terminal = Terminal()
        let keyStrokeListener = KeyStrokeListener()
        var canvas: [String: (char: String, color: (String) -> String)] = [:]
        var isDragging = false
        var currentBrushIndex = 0
        var lastPosition: TerminalPosition?
        var lastTerminalSize: TerminalSize?

        let brushes: [(char: String, color: (String) -> String)] = [
            ("●", { $0.red }),
            ("■", { $0.yellow }),
            ("★", { $0.green }),
            ("♦", { $0.blue }),
            ("♥", { $0.magenta }),
            ("⌫", { $0 }),
        ]

        print("\u{1B}[2J", terminator: "") // Clear screen
        print("\u{1B}[H", terminator: "") // Move cursor to home
        terminal.hideCursor()
        defer {
            terminal.showCursor()
            print("\u{1B}[2J\u{1B}[H") // Clear screen
        }

        terminal.inRawMode {
            terminal.withMouseTracking(trackMotion: true) {
                drawScreen(terminal: terminal, brushes: brushes, currentBrushIndex: currentBrushIndex, canvas: canvas)
                lastTerminalSize = terminal.size()

                keyStrokeListener.listen(terminal: terminal) { [self] keyStroke in
                    let currentSize = terminal.size()
                    if currentSize != lastTerminalSize {
                        drawScreen(terminal: terminal, brushes: brushes, currentBrushIndex: currentBrushIndex, canvas: canvas)
                        lastTerminalSize = currentSize
                    }

                    switch keyStroke {
                    case let .printable(character) where character == "q":
                        return .abort
                    case let .printable(character) where character == "c":
                        for (key, _) in canvas {
                            let parts = key.split(separator: ";").compactMap { Int($0) }
                            if parts.count == 2 {
                                drawPoint(TerminalPosition(row: parts[0], column: parts[1]), nil, terminal: terminal)
                            }
                        }
                        canvas.removeAll()
                        return .continue
                    case let .leftMouseDown(position):
                        isDragging = true
                        lastPosition = nil
                        draw(
                            at: position,
                            lastPosition: &lastPosition,
                            canvas: &canvas,
                            brushes: brushes,
                            currentBrushIndex: currentBrushIndex,
                            terminal: terminal
                        )
                        return .continue
                    case .leftMouseUp:
                        isDragging = false
                        lastPosition = nil
                        return .continue
                    case let .leftMouseDrag(position):
                        if isDragging {
                            draw(
                                at: position,
                                lastPosition: &lastPosition,
                                canvas: &canvas,
                                brushes: brushes,
                                currentBrushIndex: currentBrushIndex,
                                terminal: terminal
                            )
                        }
                        return .continue
                    case .rightMouseDown:
                        currentBrushIndex = (currentBrushIndex + 1) % brushes.count
                        updateBrushDisplay(brushes: brushes, currentBrushIndex: currentBrushIndex)
                        return .continue
                    default:
                        return .continue
                    }
                }
            }
        }
    }

    private func interpolatePoints(from: TerminalPosition, to: TerminalPosition) -> [TerminalPosition] {
        let dx = to.column - from.column
        let dy = to.row - from.row
        let steps = max(abs(dx), abs(dy))

        guard steps > 0 else { return [from] }

        var points: [TerminalPosition] = []
        for i in 0 ... steps {
            let t = Double(i) / Double(steps)
            let x = from.column + Int(round(Double(dx) * t))
            let y = from.row + Int(round(Double(dy) * t))
            points.append(TerminalPosition(row: y, column: x))
        }
        return points
    }

    private func positionKey(_ pos: TerminalPosition) -> String {
        "\(pos.row);\(pos.column)"
    }

    private func drawPoint(
        _ point: TerminalPosition,
        _ content: (char: String, color: (String) -> String)?,
        terminal: Terminal
    ) {
        let canvasTop = 5
        let terminalSize = terminal.size()
        let canvasWidth = (terminalSize?.columns ?? 40) - 2
        let canvasHeight = (terminalSize?.rows ?? 120) - canvasTop

        if point.row > canvasTop,
           point.row < canvasTop + canvasHeight,
           point.column > 1,
           point.column < canvasWidth + 1
        {
            print("\u{1B}[\(point.row);\(point.column)H", terminator: "")
            if let content {
                if content.char == "⌫" {
                    print(" ", terminator: "")
                } else {
                    print(content.color(content.char), terminator: "")
                }
            } else {
                print(" ", terminator: "")
            }
            fflush(stdout)
        }
    }

    private func updateBrushDisplay(
        brushes: [(char: String, color: (String) -> String)],
        currentBrushIndex: Int
    ) {
        let brush = brushes[currentBrushIndex]
        print("\u{1B}[4;1H  Current brush: \(brush.color(brush.char))    ", terminator: "")
        fflush(stdout)
    }

    private func draw(
        at position: TerminalPosition,
        lastPosition: inout TerminalPosition?,
        canvas: inout [String: (char: String, color: (String) -> String)],
        brushes: [(char: String, color: (String) -> String)],
        currentBrushIndex: Int,
        terminal: Terminal
    ) {
        let canvasTop = 5
        let terminalSize = terminal.size()
        let canvasWidth = (terminalSize?.columns ?? 40) - 2
        let canvasHeight = (terminalSize?.rows ?? 120) - canvasTop

        func isInCanvas(_ pos: TerminalPosition) -> Bool {
            pos.row > canvasTop &&
                pos.row < canvasTop + canvasHeight &&
                pos.column > 1 &&
                pos.column < canvasWidth + 1
        }

        if let last = lastPosition {
            let points = interpolatePoints(from: last, to: position)
            for point in points {
                if isInCanvas(point) {
                    let key = positionKey(point)
                    if currentBrushIndex == brushes.count - 1 {
                        if canvas[key] != nil {
                            canvas.removeValue(forKey: key)
                            drawPoint(point, nil, terminal: terminal)
                        }
                    } else {
                        let content = (char: brushes[currentBrushIndex].char, color: brushes[currentBrushIndex].color)
                        canvas[key] = content
                        drawPoint(point, content, terminal: terminal)
                    }
                }
            }
        } else {
            if isInCanvas(position) {
                let key = positionKey(position)
                if currentBrushIndex == brushes.count - 1 {
                    if canvas[key] != nil {
                        canvas.removeValue(forKey: key)
                        drawPoint(position, nil, terminal: terminal)
                    }
                } else {
                    let content = (char: brushes[currentBrushIndex].char, color: brushes[currentBrushIndex].color)
                    canvas[key] = content
                    drawPoint(position, content, terminal: terminal)
                }
            }
        }
        lastPosition = position
    }

    private func drawScreen(
        terminal: Terminal,
        brushes: [(char: String, color: (String) -> String)],
        currentBrushIndex: Int,
        canvas: [String: (char: String, color: (String) -> String)]
    ) {
        var output = "\u{1B}[2J\u{1B}[H" // Clear screen and move to home

        let brush = brushes[currentBrushIndex]
        output += Noora().format("""
          \(.accent("✨ Terminal Paint ✨"))
          • \(.primary("left click")) to draw, \(.primary("right click")) to change brush
          • \(.primary("'q'")) to quit, \(.primary("'c'")) to clear
          Current brush: \(brush.color(brush.char))

        """)

        let canvasTop = 5
        let terminalSize = terminal.size()
        let canvasWidth = (terminalSize?.columns ?? 40) - 2
        let canvasHeight = (terminalSize?.rows ?? 120) - canvasTop

        // Top border
        output += "\u{1B}[\(canvasTop);0H╭"
        output += String(repeating: "─", count: canvasWidth)
        output += "╮"

        // Side borders
        for row in 1 ... canvasHeight {
            output += "\u{1B}[\(canvasTop + row);0H│"
            output += "\u{1B}[\(canvasTop + row);\(canvasWidth + 2)H│"
        }

        // Bottom border
        output += "\u{1B}[\(canvasTop + canvasHeight + 1);0H╰"
        output += String(repeating: "─", count: canvasWidth)
        output += "╯"

        print(output, terminator: "")
        fflush(stdout)

        // Draw existing canvas points
        for (key, content) in canvas {
            let parts = key.split(separator: ";").compactMap { Int($0) }
            if parts.count == 2 {
                drawPoint(TerminalPosition(row: parts[0], column: parts[1]), content, terminal: terminal)
            }
        }
    }
}
