import SwiftUI

struct EverforestDarkTheme: TerminalThemeProtocol {
    var displayName: String { "Everforest Dark" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x232A2E),
            foreground: TerminalThemeColor(hex: 0xD3C6AA),
            accent: TerminalThemeColor(hex: 0xA7C080),
            cursor: TerminalThemeColor(hex: 0xE69875),
            chromeTop: TerminalThemeColor(hex: 0x293235),
            chromeBottom: TerminalThemeColor(hex: 0x202729),
            sidebarTop: TerminalThemeColor(hex: 0x283034),
            sidebarBottom: TerminalThemeColor(hex: 0x232A2E),
            card: TerminalThemeColor(hex: 0x2F383E),
            cardBorder: TerminalThemeColor(hex: 0x475258),
            normalANSI: [
                TerminalThemeColor(hex: 0x374145), TerminalThemeColor(hex: 0xE67E80),
                TerminalThemeColor(hex: 0xA7C080), TerminalThemeColor(hex: 0xDBBC7F),
                TerminalThemeColor(hex: 0x7FBBB3), TerminalThemeColor(hex: 0xD699B6),
                TerminalThemeColor(hex: 0x83C092), TerminalThemeColor(hex: 0xD3C6AA)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x859289), TerminalThemeColor(hex: 0xF0959B),
                TerminalThemeColor(hex: 0xB8D39C), TerminalThemeColor(hex: 0xF0D399),
                TerminalThemeColor(hex: 0x9ACFC5), TerminalThemeColor(hex: 0xE6B4CD),
                TerminalThemeColor(hex: 0xA6D6A7), TerminalThemeColor(hex: 0xFFF9E8)
            ]
        )
    }
}
