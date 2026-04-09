import SwiftUI

struct KanagawaDragonTheme: TerminalThemeProtocol {
    var displayName: String { "Kanagawa Dragon" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x181616),
            foreground: TerminalThemeColor(hex: 0xC5C9C5),
            accent: TerminalThemeColor(hex: 0x8BA4B0),
            cursor: TerminalThemeColor(hex: 0xC5C9C5),
            chromeTop: TerminalThemeColor(hex: 0x211F1F),
            chromeBottom: TerminalThemeColor(hex: 0x181616),
            sidebarTop: TerminalThemeColor(hex: 0x201E1E),
            sidebarBottom: TerminalThemeColor(hex: 0x181616),
            card: TerminalThemeColor(hex: 0x262323),
            cardBorder: TerminalThemeColor(hex: 0x3E3B3B),
            normalANSI: [
                TerminalThemeColor(hex: 0x0D0C0C), TerminalThemeColor(hex: 0xC4746E),
                TerminalThemeColor(hex: 0x8A9A7B), TerminalThemeColor(hex: 0xC4B28A),
                TerminalThemeColor(hex: 0x8BA4B0), TerminalThemeColor(hex: 0xA292A3),
                TerminalThemeColor(hex: 0x8EA4A2), TerminalThemeColor(hex: 0xC5C9C5)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x7A8382), TerminalThemeColor(hex: 0xE46876),
                TerminalThemeColor(hex: 0x87A987), TerminalThemeColor(hex: 0xE6C384),
                TerminalThemeColor(hex: 0x7FB4CA), TerminalThemeColor(hex: 0x938AA9),
                TerminalThemeColor(hex: 0x7AA89F), TerminalThemeColor(hex: 0xE6E9E6)
            ]
        )
    }
}
