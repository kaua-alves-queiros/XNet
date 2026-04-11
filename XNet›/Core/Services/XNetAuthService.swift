import Foundation
import Combine

class XNetAuthService: ObservableObject {
    static let shared = XNetAuthService()
    
    @Published var isAuthenticating = false
    @Published var lastError: String?
    
    private let connectivityStore = XNetConnectivityStore.shared
    
    func login(email: String, password: String) async -> Bool {
        guard let url = URL(string: "\(connectivityStore.serverUrl)/api/auth/login") else {
            DispatchQueue.main.async { self.lastError = "URL Inválida" }
            return false
        }
        
        DispatchQueue.main.async {
            self.isAuthenticating = true
            self.lastError = nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            if httpResponse.statusCode == 200 {
                let authResponse = try JSONDecoder().decode(AuthData.self, from: data)
                DispatchQueue.main.async {
                    self.connectivityStore.apiToken = authResponse.token
                    self.isAuthenticating = false
                }
                return true
            } else {
                DispatchQueue.main.async {
                    self.lastError = "Falha no Login (\(httpResponse.statusCode))"
                    self.isAuthenticating = false
                }
                return false
            }
        } catch {
            DispatchQueue.main.async {
                self.lastError = "Erro de Conexão: \(error.localizedDescription)"
                self.isAuthenticating = false
            }
            return false
        }
    }
    
    struct AuthData: Codable {
        let token: String
        let expiresAt: String // Mudamos para String para evitar erros de parsing de data do C#
    }
}
