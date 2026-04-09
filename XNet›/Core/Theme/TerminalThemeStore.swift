import SwiftUI

enum TerminalThemeStore {
    static let storageKey = "terminal.theme.selected.v1"
    static let didChangeNotification = Notification.Name("TerminalThemeChanged")
    
    static func readThemeID() -> String {
        UserDefaults.standard.string(forKey: storageKey) ?? TerminalTheme.defaultTheme.rawValue
    }
    
    static func saveThemeID(_ themeID: String) {
        UserDefaults.standard.set(themeID, forKey: storageKey)
        NotificationCenter.default.post(name: didChangeNotification, object: themeID)
    }
}
