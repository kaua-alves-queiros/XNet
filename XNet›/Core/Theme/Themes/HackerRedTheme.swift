import SwiftUI

struct HackerRedTheme: TerminalThemeProtocol {
    var displayName: String { "Hacker Red" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x190506),
            foreground: TerminalThemeColor(hex: 0xFF8A8A),
            accent: TerminalThemeColor(hex: 0xFF3B3B),
            cursor: TerminalThemeColor(hex: 0xFF7575),
            chromeTop: TerminalThemeColor(hex: 0x260B0D),
            chromeBottom: TerminalThemeColor(hex: 0x190506),
            sidebarTop: TerminalThemeColor(hex: 0x240A0C),
            sidebarBottom: TerminalThemeColor(hex: 0x180506),
            card: TerminalThemeColor(hex: 0x2B0E11),
            cardBorder: TerminalThemeColor(hex: 0x5D1E25),
            normalANSI: [
                TerminalThemeColor(hex: 0x2D1115), TerminalThemeColor(hex: 0xE03131),
                TerminalThemeColor(hex: 0xFF6961), TerminalThemeColor(hex: 0xFF8C5A),
                TerminalThemeColor(hex: 0xC93C50), TerminalThemeColor(hex: 0xFF5C7A),
                TerminalThemeColor(hex: 0xFF7B72), TerminalThemeColor(hex: 0xFFD7D7)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x6A3137), TerminalThemeColor(hex: 0xFF6B6B),
                TerminalThemeColor(hex: 0xFF8A80), TerminalThemeColor(hex: 0xFFA06B),
                TerminalThemeColor(hex: 0xFF7285), TerminalThemeColor(hex: 0xFF91A4),
                TerminalThemeColor(hex: 0xFFADA7), TerminalThemeColor(hex: 0xFFF2F2)
            ]
        )
    }
}
