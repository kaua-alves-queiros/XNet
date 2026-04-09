import SwiftUI
import AppKit

enum TerminalTheme: String, CaseIterable, Identifiable {
    case termiusDark = "termius-dark"
    case termiusLight = "termius-light"
    case flexokiDark = "flexoki-dark"
    case flexokiLight = "flexoki-light"
    case kanagawaWave = "kanagawa-wave"
    case kanagawaDragon = "kanagawa-dragon"
    case hackerBlue = "hacker-blue"
    case hackerGreen = "hacker-green"
    case hackerRed = "hacker-red"
    case everforestDark = "everforest-dark"
    case nightOwl = "night-owl"
    case rosePineMoon = "rose-pine-moon"
    case native = "native"
    
    var id: String { rawValue }
    
    static var defaultTheme: TerminalTheme { .termiusDark }
    
    private var provider: TerminalThemeProtocol {
        switch self {
        case .termiusDark: return TermiusDarkTheme()
        case .termiusLight: return TermiusLightTheme()
        case .flexokiDark: return FlexokiDarkTheme()
        case .flexokiLight: return FlexokiLightTheme()
        case .kanagawaWave: return KanagawaWaveTheme()
        case .kanagawaDragon: return KanagawaDragonTheme()
        case .hackerBlue: return HackerBlueTheme()
        case .hackerGreen: return HackerGreenTheme()
        case .hackerRed: return HackerRedTheme()
        case .everforestDark: return EverforestDarkTheme()
        case .nightOwl: return NightOwlTheme()
        case .rosePineMoon: return RosePineMoonTheme()
        case .native: return NativeTheme()
        }
    }
    
    var displayName: String { provider.displayName }
    var isLight: Bool { provider.isLight }
    var backgroundColor: Color { provider.backgroundColor }
    var foregroundColor: Color { provider.foregroundColor }
    var accentColor: Color { provider.accentColor }
    var cursorColor: Color { provider.cursorColor }
    var chromeTopColor: Color { provider.chromeTopColor }
    var chromeBottomColor: Color { provider.chromeBottomColor }
    var sidebarTopColor: Color { provider.sidebarTopColor }
    var sidebarBottomColor: Color { provider.sidebarBottomColor }
    var cardBackgroundColor: Color { provider.cardBackgroundColor }
    var panelBorderColor: Color { provider.panelBorderColor }
    var mutedColor: Color { foregroundColor.opacity(isLight ? 0.62 : 0.58) }
    
    var defaultForegroundNSColor: NSColor { provider.defaultForegroundNSColor }
    var defaultBackgroundNSColor: NSColor { provider.defaultBackgroundNSColor }
    var cursorNSColor: NSColor { provider.cursorNSColor }
    var selectionNSColor: NSColor { provider.selectionNSColor }
    
    var appearanceLabel: String { isLight ? "Claro" : "Escuro" }
    
    var previewSwatches: [Color] {
        let spec = provider.spec
        return [
            accentColor,
            spec.normalANSI[1].color,
            spec.normalANSI[2].color,
            spec.brightANSI[4].color
        ]
    }
    
    func ansiColor(index: Int, bright: Bool) -> NSColor {
        let palette = bright ? provider.spec.brightANSI : provider.spec.normalANSI
        guard index >= 0, index < palette.count else {
            return defaultForegroundNSColor
        }
        return palette[index].nsColor
    }
}
