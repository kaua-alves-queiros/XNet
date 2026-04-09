import SwiftUI

struct RosePineMoonTheme: TerminalThemeProtocol {
    var displayName: String { "Rosé Pine Moon" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x232136),
            foreground: TerminalThemeColor(hex: 0xE0DEF4),
            accent: TerminalThemeColor(hex: 0xC4A7E7),
            cursor: TerminalThemeColor(hex: 0xEA9A97),
            chromeTop: TerminalThemeColor(hex: 0x2A273F),
            chromeBottom: TerminalThemeColor(hex: 0x201E31),
            sidebarTop: TerminalThemeColor(hex: 0x2A273F),
            sidebarBottom: TerminalThemeColor(hex: 0x232136),
            card: TerminalThemeColor(hex: 0x2F2B46),
            cardBorder: TerminalThemeColor(hex: 0x4A446B),
            normalANSI: [
                TerminalThemeColor(hex: 0x393552), TerminalThemeColor(hex: 0xEB6F92),
                TerminalThemeColor(hex: 0x3E8FB0), TerminalThemeColor(hex: 0xF6C177),
                TerminalThemeColor(hex: 0x9CCFD8), TerminalThemeColor(hex: 0xC4A7E7),
                TerminalThemeColor(hex: 0xEA9A97), TerminalThemeColor(hex: 0xE0DEF4)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x6E6A86), TerminalThemeColor(hex: 0xFF8BA7),
                TerminalThemeColor(hex: 0x6FB4D8), TerminalThemeColor(hex: 0xFFD08F),
                TerminalThemeColor(hex: 0xB8E5EE), TerminalThemeColor(hex: 0xD9C3F6),
                TerminalThemeColor(hex: 0xF6B8B3), TerminalThemeColor(hex: 0xF6F3FF)
            ]
        )
    }
}
