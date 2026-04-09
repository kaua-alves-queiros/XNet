import SwiftUI

struct FlexokiLightTheme: TerminalThemeProtocol {
    var displayName: String { "Flexoki Light" }
    var isLight: Bool { true }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0xFFFCF0),
            foreground: TerminalThemeColor(hex: 0x100F0F),
            accent: TerminalThemeColor(hex: 0xD14D41),
            cursor: TerminalThemeColor(hex: 0x100F0F),
            chromeTop: TerminalThemeColor(hex: 0xFFFDF7),
            chromeBottom: TerminalThemeColor(hex: 0xF2EDE1),
            sidebarTop: TerminalThemeColor(hex: 0xFFF9EB),
            sidebarBottom: TerminalThemeColor(hex: 0xF4EFE2),
            card: TerminalThemeColor(hex: 0xFFFDF7),
            cardBorder: TerminalThemeColor(hex: 0xD8D1C0),
            normalANSI: [
                TerminalThemeColor(hex: 0x6F6E69), TerminalThemeColor(hex: 0xAF3029),
                TerminalThemeColor(hex: 0x66800B), TerminalThemeColor(hex: 0xAD8301),
                TerminalThemeColor(hex: 0x205EA6), TerminalThemeColor(hex: 0xA02F6F),
                TerminalThemeColor(hex: 0x24837B), TerminalThemeColor(hex: 0xE6E0D1)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x878580), TerminalThemeColor(hex: 0xD14D41),
                TerminalThemeColor(hex: 0x879A39), TerminalThemeColor(hex: 0xD0A215),
                TerminalThemeColor(hex: 0x4385BE), TerminalThemeColor(hex: 0xCE5D97),
                TerminalThemeColor(hex: 0x3AA99F), TerminalThemeColor(hex: 0x1C1B1A)
            ]
        )
    }
}
