import SwiftUI
import Combine

enum XNetConnectionMode: String, CaseIterable, Identifiable {
    case standalone = "Standalone"
    case selfHosted = "Self-Hosted"
    case cloud = "Cloud (Em Breve)"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .standalone: return "laptopcomputer"
        case .selfHosted: return "server.rack"
        case .cloud: return "cloud.fill"
        }
    }
}

class XNetConnectivityStore: ObservableObject {
    static let shared = XNetConnectivityStore()
    
    private let modeKey = "xnet.connection.mode"
    private let serverUrlKey = "xnet.server.url"
    private let apiTokenKey = "xnet.api.token"
    
    @Published var mode: XNetConnectionMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: modeKey) }
    }
    
    @Published var serverUrl: String {
        didSet { UserDefaults.standard.set(serverUrl, forKey: serverUrlKey) }
    }
    
    @Published var apiToken: String {
        didSet { UserDefaults.standard.set(apiToken, forKey: apiTokenKey) }
    }
    
    private init() {
        let savedMode = UserDefaults.standard.string(forKey: modeKey) ?? XNetConnectionMode.standalone.rawValue
        self.mode = XNetConnectionMode(rawValue: savedMode) ?? .standalone
        self.serverUrl = UserDefaults.standard.string(forKey: serverUrlKey) ?? "http://localhost:5239"
        self.apiToken = UserDefaults.standard.string(forKey: apiTokenKey) ?? ""
    }
    
    func testConnection() async -> Bool {
        guard let url = URL(string: "\(serverUrl)/api/system/handshake") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
}
