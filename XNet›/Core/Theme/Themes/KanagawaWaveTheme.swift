import SwiftUI

struct KanagawaWaveTheme: TerminalThemeProtocol {
    var displayName: String { "Kanagawa Wave" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x1F1F28),
            foreground: TerminalThemeColor(hex: 0xDCD7BA),
            accent: TerminalThemeColor(hex: 0x7E9CD8),
            cursor: TerminalThemeColor(hex: 0xC8C093),
            chromeTop: TerminalThemeColor(hex: 0x252532),
            chromeBottom: TerminalThemeColor(hex: 0x1B1B24),
            sidebarTop: TerminalThemeColor(hex: 0x242531),
            sidebarBottom: TerminalThemeColor(hex: 0x1F1F28),
            card: TerminalThemeColor(hex: 0x2A2A37),
            cardBorder: TerminalThemeColor(hex: 0x3A3A4C),
            normalANSI: [
                TerminalThemeColor(hex: 0x090618), TerminalThemeColor(hex: 0xC34043),
                TerminalThemeColor(hex: 0x76946A), TerminalThemeColor(hex: 0xC0A36E),
                TerminalThemeColor(hex: 0x7E9CD8), TerminalThemeColor(hex: 0x957FB8),
                TerminalThemeColor(hex: 0x6A9589), TerminalThemeColor(hex: 0xC8C093)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x727169), TerminalThemeColor(hex: 0xE82424),
                TerminalThemeColor(hex: 0x98BB6C), TerminalThemeColor(hex: 0xE6C384),
                TerminalThemeColor(hex: 0x7FB4CA), TerminalThemeColor(hex: 0x938AA9),
                TerminalThemeColor(hex: 0x7AA89F), TerminalThemeColor(hex: 0xDCD7BA)
            ]
        )
    }
}
