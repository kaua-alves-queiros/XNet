import SwiftUI
import AppKit

struct TerminalThemeColor: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(hex: Int, alpha: Double = 1.0) {
        self.red = Double((hex >> 16) & 0xFF) / 255.0
        self.green = Double((hex >> 8) & 0xFF) / 255.0
        self.blue = Double(hex & 0xFF) / 255.0
        self.alpha = alpha
    }
    
    var nsColor: NSColor {
        NSColor(
            calibratedRed: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }
    
    var color: Color {
        Color(nsColor: nsColor)
    }
    
    func withAlpha(_ value: Double) -> TerminalThemeColor {
        TerminalThemeColor(red: red, green: green, blue: blue, alpha: value)
    }
}

struct TerminalThemeSpec {
    let background: TerminalThemeColor
    let foreground: TerminalThemeColor
    let accent: TerminalThemeColor
    let cursor: TerminalThemeColor
    let chromeTop: TerminalThemeColor
    let chromeBottom: TerminalThemeColor
    let sidebarTop: TerminalThemeColor
    let sidebarBottom: TerminalThemeColor
    let card: TerminalThemeColor
    let cardBorder: TerminalThemeColor
    let normalANSI: [TerminalThemeColor]
    let brightANSI: [TerminalThemeColor]
}
