import SwiftUI

struct HackerGreenTheme: TerminalThemeProtocol {
    var displayName: String { "Hacker Green" }
    var isLight: Bool { false }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(hex: 0x08140A),
            foreground: TerminalThemeColor(hex: 0x7BFFA0),
            accent: TerminalThemeColor(hex: 0x15F05D),
            cursor: TerminalThemeColor(hex: 0x7BFFA0),
            chromeTop: TerminalThemeColor(hex: 0x102014),
            chromeBottom: TerminalThemeColor(hex: 0x08140A),
            sidebarTop: TerminalThemeColor(hex: 0x102014),
            sidebarBottom: TerminalThemeColor(hex: 0x09140A),
            card: TerminalThemeColor(hex: 0x122617),
            cardBorder: TerminalThemeColor(hex: 0x244D2E),
            normalANSI: [
                TerminalThemeColor(hex: 0x0D1F10), TerminalThemeColor(hex: 0x12B44B),
                TerminalThemeColor(hex: 0x0DD45A), TerminalThemeColor(hex: 0x58E77B),
                TerminalThemeColor(hex: 0x24C67D), TerminalThemeColor(hex: 0x4AEF9A),
                TerminalThemeColor(hex: 0x58F7BE), TerminalThemeColor(hex: 0xD4FFE0)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x3D6846), TerminalThemeColor(hex: 0x38EA76),
                TerminalThemeColor(hex: 0x6FFF9D), TerminalThemeColor(hex: 0x9BFFBF),
                TerminalThemeColor(hex: 0x7DFFB9), TerminalThemeColor(hex: 0xA2FFD0),
                TerminalThemeColor(hex: 0xB8FFE5), TerminalThemeColor(hex: 0xF1FFF5)
            ]
        )
    }
}
