import Foundation

struct XNetTerminalTab: Identifiable {
    let id = UUID()
    var name: String
    var connectionType: XNetTerminalConnectionType = .ssh
    var host: String = ""
    var port: String = "22"
    var username: String = ""
    var password: String = ""
    var availableSerialPorts: [String] = []
    var manager: TerminalConnectionManager = TerminalConnectionManager()
    var sessionStartedAt: Date?
    var persistedLogSignature: String?
    
    var displayName: String {
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedHost.isEmpty ? name : trimmedHost
    }
}
