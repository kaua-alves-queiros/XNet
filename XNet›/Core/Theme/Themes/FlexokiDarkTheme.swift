import SwiftUI

struct FlexokiDarkTheme: TerminalThemeProtocol {
    var displayName: String { "Flexoki Dark" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x100F0F),
            foreground: TerminalThemeColor(hex: 0xCECDC3),
            accent: TerminalThemeColor(hex: 0xD14D41),
            cursor: TerminalThemeColor(hex: 0xCECDC3),
            chromeTop: TerminalThemeColor(hex: 0x1A1818),
            chromeBottom: TerminalThemeColor(hex: 0x121111),
            sidebarTop: TerminalThemeColor(hex: 0x181616),
            sidebarBottom: TerminalThemeColor(hex: 0x100F0F),
            card: TerminalThemeColor(hex: 0x1C1B1A),
            cardBorder: TerminalThemeColor(hex: 0x343331),
            normalANSI: [
                TerminalThemeColor(hex: 0x403E3C), TerminalThemeColor(hex: 0xAF3029),
                TerminalThemeColor(hex: 0x66800B), TerminalThemeColor(hex: 0xAD8301),
                TerminalThemeColor(hex: 0x205EA6), TerminalThemeColor(hex: 0xA02F6F),
                TerminalThemeColor(hex: 0x24837B), TerminalThemeColor(hex: 0x878580)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x575653), TerminalThemeColor(hex: 0xD14D41),
                TerminalThemeColor(hex: 0x879A39), TerminalThemeColor(hex: 0xD0A215),
                TerminalThemeColor(hex: 0x4385BE), TerminalThemeColor(hex: 0xCE5D97),
                TerminalThemeColor(hex: 0x3AA99F), TerminalThemeColor(hex: 0xFFFCF0)
            ]
        )
    }
}
