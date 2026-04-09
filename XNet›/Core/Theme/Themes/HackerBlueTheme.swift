import SwiftUI

struct HackerBlueTheme: TerminalThemeProtocol {
    var displayName: String { "Hacker Blue" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x03121F),
            foreground: TerminalThemeColor(hex: 0x7CDFFF),
            accent: TerminalThemeColor(hex: 0x00B8FF),
            cursor: TerminalThemeColor(hex: 0x39D5FF),
            chromeTop: TerminalThemeColor(hex: 0x081D30),
            chromeBottom: TerminalThemeColor(hex: 0x03121F),
            sidebarTop: TerminalThemeColor(hex: 0x081A2A),
            sidebarBottom: TerminalThemeColor(hex: 0x04111D),
            card: TerminalThemeColor(hex: 0x082034),
            cardBorder: TerminalThemeColor(hex: 0x16405A),
            normalANSI: [
                TerminalThemeColor(hex: 0x03283A), TerminalThemeColor(hex: 0x0F9BDD),
                TerminalThemeColor(hex: 0x00C2A8), TerminalThemeColor(hex: 0x16A6FF),
                TerminalThemeColor(hex: 0x0A84FF), TerminalThemeColor(hex: 0x45B8FF),
                TerminalThemeColor(hex: 0x00D1FF), TerminalThemeColor(hex: 0xC6F6FF)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x1D536A), TerminalThemeColor(hex: 0x44C7FF),
                TerminalThemeColor(hex: 0x42F8D2), TerminalThemeColor(hex: 0x6BD0FF),
                TerminalThemeColor(hex: 0x69B8FF), TerminalThemeColor(hex: 0x8DD6FF),
                TerminalThemeColor(hex: 0x78EBFF), TerminalThemeColor(hex: 0xE7FCFF)
            ]
        )
    }
}
