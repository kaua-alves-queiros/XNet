import SwiftUI
import AppKit

protocol TerminalThemeProtocol {
    var displayName: String { get }
    var isLight: Bool { get }
    var spec: TerminalThemeSpec { get }
    
    // Optional overrides for native behaviors
    var backgroundColor: Color { get }
    var foregroundColor: Color { get }
    var accentColor: Color { get }
    var cursorColor: Color { get }
    var chromeTopColor: Color { get }
    var chromeBottomColor: Color { get }
    var sidebarTopColor: Color { get }
    var sidebarBottomColor: Color { get }
    var cardBackgroundColor: Color { get }
    var panelBorderColor: Color { get }
    
    var defaultForegroundNSColor: NSColor { get }
    var defaultBackgroundNSColor: NSColor { get }
    var cursorNSColor: NSColor { get }
    var selectionNSColor: NSColor { get }
}

extension TerminalThemeProtocol {
    var backgroundColor: Color { spec.background.color }
    var foregroundColor: Color { spec.foreground.color }
    var accentColor: Color { spec.accent.color }
    var cursorColor: Color { spec.cursor.color }
    var chromeTopColor: Color { spec.chromeTop.color }
    var chromeBottomColor: Color { spec.chromeBottom.color }
    var sidebarTopColor: Color { spec.sidebarTop.color }
    var sidebarBottomColor: Color { spec.sidebarBottom.color }
    var cardBackgroundColor: Color { spec.card.color }
    var panelBorderColor: Color { spec.cardBorder.color }
    
    var defaultForegroundNSColor: NSColor { spec.foreground.nsColor }
    var defaultBackgroundNSColor: NSColor { spec.background.nsColor }
    var cursorNSColor: NSColor { spec.cursor.nsColor }
    var selectionNSColor: NSColor { spec.accent.withAlpha(isLight ? 0.24 : 0.32).nsColor }
}
