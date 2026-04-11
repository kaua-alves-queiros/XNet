import Foundation
import Combine

enum SyncStrategy: String {
    case pull = "PULL"
    case push = "PUSH"
    case merge = "MERGE"
}

class XNetSyncService: ObservableObject {
    static let shared = XNetSyncService()
    
    @Published var isSyncing = false
    @Published var progressMessage = ""
    
    private let connectivityStore = XNetConnectivityStore.shared
    
    func performSync(strategy: SyncStrategy) async -> Bool {
        DispatchQueue.main.async { 
            self.isSyncing = true
            self.progressMessage = "Preparando canais de sincronização..."
        }
        
        switch strategy {
        case .pull:
            return await pullFromServer()
        case .push:
            return await pushToServer()
        case .merge:
            return await mergeData()
        }
    }
    
    private func pullFromServer() async -> Bool {
        DispatchQueue.main.async { self.progressMessage = "Baixando backup completo do servidor..." }
        
        guard let url = URL(string: "\(connectivityStore.serverUrl)/api/sync/export") else { return false }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(connectivityStore.apiToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return false }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(FullSyncPayload.self, from: data)
            
            // 1. Restaurar Terminal
            if let devices = result.devices {
                let local = devices.map { d in XNetTerminalDevice(id: d.id, name: d.name, groupName: "Remote", connectionType: d.connectionType, host: d.host, port: d.port, username: d.username ?? "", credentialID: UUID().uuidString, notes: d.notes ?? "", createdAt: Date()) }
                if let encoded = try? JSONEncoder().encode(local) { UserDefaults.standard.set(encoded, forKey: XNetTerminalDevice.storageKey) }
            }
            
            if let snippets = result.snippets {
                let local = snippets.map { s in XNetTerminalSnippet(id: s.id, title: s.title, command: s.command, notes: s.notes ?? "", sendReturn: s.sendReturn) }
                if let encoded = try? JSONEncoder().encode(local) { UserDefaults.standard.set(encoded, forKey: XNetTerminalSnippet.storageKey) }
            }
            
            // 2. Notificar recarregamento de UI
            DispatchQueue.main.async { 
                NotificationCenter.default.post(name: NSNotification.Name("TerminalDataReload"), object: nil)
                self.isSyncing = false 
            }
            return true
        } catch {
            print("Full Sync Pull Error: \(error)")
            DispatchQueue.main.async { self.isSyncing = false }
            return false
        }
    }
    
    private func pushToServer() async -> Bool {
        DispatchQueue.main.async { self.progressMessage = "Enviando todos os seus dados (Terminal + NetBox)..." }
        
        // Coletar dados locais do Terminal
        let localDevices: [XNetTerminalDevice] = (try? JSONDecoder().decode([XNetTerminalDevice].self, from: UserDefaults.standard.data(forKey: XNetTerminalDevice.storageKey) ?? Data())) ?? []
        let localSnippets: [XNetTerminalSnippet] = (try? JSONDecoder().decode([XNetTerminalSnippet].self, from: UserDefaults.standard.data(forKey: XNetTerminalSnippet.storageKey) ?? Data())) ?? []
        let localLogs: [XNetTerminalLog] = (try? JSONDecoder().decode([XNetTerminalLog].self, from: UserDefaults.standard.data(forKey: XNetTerminalLog.storageKey) ?? Data())) ?? []
        
        let payload = FullSyncPayload(
            strategy: "PUSH",
            devices: localDevices.map { DevicePayload(id: $0.id, name: $0.name, host: $0.host, port: $0.port, connectionType: $0.connectionType, username: $0.username, notes: $0.notes) },
            snippets: localSnippets.map { SnippetPayload(id: $0.id, title: $0.title, command: $0.command, notes: $0.notes, sendReturn: $0.sendReturn) },
            logs: localLogs.map { LogPayload(id: $0.id, title: $0.title, host: $0.host, port: $0.port, username: $0.username, content: $0.content) }
        )
        
        return await sendSyncRequest(payload)
    }
    
    private func mergeData() async -> Bool {
        // Por simplicidade no MVP de full sync, o merge vai se comportar como PUSH seguido de PULL no servidor
        return await pushToServer()
    }
    
    private func sendSyncRequest(_ payload: FullSyncPayload) async -> Bool {
        guard let url = URL(string: "\(connectivityStore.serverUrl)/api/sync/import") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(connectivityStore.apiToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(payload)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { if !success { self.isSyncing = false } }
            return success
        } catch {
            DispatchQueue.main.async { self.isSyncing = false }
            return false
        }
    }
    
    // MARK: - Models
    struct FullSyncPayload: Codable {
        var strategy: String = "MERGE"
        var devices: [DevicePayload]?
        var snippets: [SnippetPayload]?
        var logs: [LogPayload]?
        // NetBox pode ser adicionado aqui seguindo o mesmo padrão
    }
    
    struct DevicePayload: Codable {
        let id: UUID
        let name: String
        let host: String
        let port: String
        let connectionType: String
        let username: String?
        let notes: String?
    }
    
    struct SnippetPayload: Codable {
        let id: UUID
        let title: String
        let command: String
        let notes: String?
        let sendReturn: Bool
    }
    
    struct LogPayload: Codable {
        let id: UUID
        let title: String
        let host: String
        let port: String
        let username: String?
        let content: String
    }
}
