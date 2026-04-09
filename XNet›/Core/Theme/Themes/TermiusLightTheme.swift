import SwiftUI

struct TermiusLightTheme: TerminalThemeProtocol {
    var displayName: String { "Termius Light" }
    var isLight: Bool { true }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0xF5F7FB),
            foreground: TerminalThemeColor(hex: 0x223046),
            accent: TerminalThemeColor(hex: 0x4F6EF7),
            cursor: TerminalThemeColor(hex: 0x3451E6),
            chromeTop: TerminalThemeColor(hex: 0xFFFFFF),
            chromeBottom: TerminalThemeColor(hex: 0xE9EEF7),
            sidebarTop: TerminalThemeColor(hex: 0xF8FAFE),
            sidebarBottom: TerminalThemeColor(hex: 0xEBF0F9),
            card: TerminalThemeColor(hex: 0xFFFFFF),
            cardBorder: TerminalThemeColor(hex: 0xCFD8E8),
            normalANSI: [
                TerminalThemeColor(hex: 0x5A6475), TerminalThemeColor(hex: 0xD64550),
                TerminalThemeColor(hex: 0x258A55), TerminalThemeColor(hex: 0xB37A0B),
                TerminalThemeColor(hex: 0x3556C5), TerminalThemeColor(hex: 0x8B4FC9),
                TerminalThemeColor(hex: 0x147A86), TerminalThemeColor(hex: 0xDCE3EF)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x7A879B), TerminalThemeColor(hex: 0xF05C67),
                TerminalThemeColor(hex: 0x31B56E), TerminalThemeColor(hex: 0xD9A634),
                TerminalThemeColor(hex: 0x5E7CFF), TerminalThemeColor(hex: 0xAF7AF3),
                TerminalThemeColor(hex: 0x2AA9B7), TerminalThemeColor(hex: 0x1B2435)
            ]
        )
    }
}
