import SwiftUI

struct NightOwlTheme: TerminalThemeProtocol {
    var displayName: String { "Night Owl" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x011627),
            foreground: TerminalThemeColor(hex: 0xD6DEEB),
            accent: TerminalThemeColor(hex: 0x7FDBCA),
            cursor: TerminalThemeColor(hex: 0x80A4C2),
            chromeTop: TerminalThemeColor(hex: 0x0B2137),
            chromeBottom: TerminalThemeColor(hex: 0x051321),
            sidebarTop: TerminalThemeColor(hex: 0x0A1E32),
            sidebarBottom: TerminalThemeColor(hex: 0x041421),
            card: TerminalThemeColor(hex: 0x10243D),
            cardBorder: TerminalThemeColor(hex: 0x24405E),
            normalANSI: [
                TerminalThemeColor(hex: 0x01111D), TerminalThemeColor(hex: 0xEF5350),
                TerminalThemeColor(hex: 0x22DA6E), TerminalThemeColor(hex: 0xC5E478),
                TerminalThemeColor(hex: 0x82AAFF), TerminalThemeColor(hex: 0xC792EA),
                TerminalThemeColor(hex: 0x21C7A8), TerminalThemeColor(hex: 0xFFFFFF)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x575656), TerminalThemeColor(hex: 0xFF869A),
                TerminalThemeColor(hex: 0x7FE089), TerminalThemeColor(hex: 0xD6DEEB),
                TerminalThemeColor(hex: 0xB2C5FF), TerminalThemeColor(hex: 0xD4BFFF),
                TerminalThemeColor(hex: 0x7FE7D8), TerminalThemeColor(hex: 0xFFFFFF)
            ]
        )
    }
}
