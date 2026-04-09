import SwiftUI
import AppKit

struct NativeTheme: TerminalThemeProtocol {
    var displayName: String { "Native macOS" }
    
    var isLight: Bool {
        if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            return appearance == .aqua
        }
        return false
    }
    
    var spec: TerminalThemeSpec {
        TerminalThemeSpec(
            background: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            foreground: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            accent: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            cursor: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            chromeTop: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            chromeBottom: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            sidebarTop: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            sidebarBottom: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            card: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            cardBorder: TerminalThemeColor(red: 0, green: 0, blue: 0, alpha: 0),
            normalANSI: [
                TerminalThemeColor(hex: 0x000000), TerminalThemeColor(hex: 0xAF0000),
                TerminalThemeColor(hex: 0x00AF00), TerminalThemeColor(hex: 0xAF5F00),
                TerminalThemeColor(hex: 0x0000AF), TerminalThemeColor(hex: 0xAF00AF),
                TerminalThemeColor(hex: 0x00AFAF), TerminalThemeColor(hex: 0xBCBCBC)
            ],
            brightANSI: [
                TerminalThemeColor(hex: 0x585858), TerminalThemeColor(hex: 0xFF5F5F),
                TerminalThemeColor(hex: 0x87AF87), TerminalThemeColor(hex: 0xFFFF87),
                TerminalThemeColor(hex: 0x5F87FF), TerminalThemeColor(hex: 0xAF87FF),
                TerminalThemeColor(hex: 0x5FFFFF), TerminalThemeColor(hex: 0xFFFFFF)
            ]
        )
    }
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var foregroundColor: Color { Color(NSColor.labelColor) }
    var accentColor: Color { Color.accentColor }
    var cursorColor: Color { Color(NSColor.labelColor) }
    var chromeTopColor: Color { Color(NSColor.windowBackgroundColor) }
    var chromeBottomColor: Color { Color(NSColor.windowBackgroundColor) }
    var sidebarTopColor: Color { Color(NSColor.windowBackgroundColor) }
    var sidebarBottomColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackgroundColor: Color { Color(NSColor.controlBackgroundColor) }
    var panelBorderColor: Color { Color(NSColor.separatorColor) }
    
    var defaultForegroundNSColor: NSColor { NSColor.labelColor }
    var defaultBackgroundNSColor: NSColor { NSColor.windowBackgroundColor }
    var cursorNSColor: NSColor { NSColor.labelColor }
    var selectionNSColor: NSColor { NSColor.selectedTextBackgroundColor }
}
