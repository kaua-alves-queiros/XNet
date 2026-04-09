import SwiftUI

struct TermiusDarkTheme: TerminalThemeProtocol {
    var displayName: String { "Termius Dark" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x121826),
            foreground: TerminalThemeColor(hex: 0xE5E9F0),
            accent: TerminalThemeColor(hex: 0x27D796),
            cursor: TerminalThemeColor(hex: 0x6EF7C8),
            chromeTop: TerminalThemeColor(hex: 0x1A2235),
            chromeBottom: TerminalThemeColor(hex: 0x111725),
            sidebarTop: TerminalThemeColor(hex: 0x182134),
            sidebarBottom: TerminalThemeColor(hex: 0x121826),
            card: TerminalThemeColor(hex: 0x1C2740),
            cardBorder: TerminalThemeColor(hex: 0x2C3A59),
            normalANSI: [
                TerminalThemeColor(hex: 0x1B2438), TerminalThemeColor(hex: 0xE05F65),
                TerminalThemeColor(hex: 0x48C774), TerminalThemeColor(hex: 0xE5C07B),
                TerminalThemeColor(hex: 0x61AFEF), TerminalThemeColor(hex: 0xC678DD),
                TerminalThemeColor(hex: 0x56B6C2), TerminalThemeColor(hex: 0xC8D1E3)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x5A6680), TerminalThemeColor(hex: 0xFF7A82),
                TerminalThemeColor(hex: 0x7FFFB2), TerminalThemeColor(hex: 0xFFD479),
                TerminalThemeColor(hex: 0x7FC8FF), TerminalThemeColor(hex: 0xE1A6FF),
                TerminalThemeColor(hex: 0x7EE7E7), TerminalThemeColor(hex: 0xF5F7FB)
            ]
        )
    }
}
