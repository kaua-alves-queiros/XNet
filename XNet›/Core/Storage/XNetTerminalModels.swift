import Foundation

enum XNetTerminalConnectionType: String, Codable, CaseIterable, Identifiable {
    case ssh = "SSH", telnet = "Telnet", serial = "Serial"
    var id: String { self.rawValue }
}

struct XNetTerminalDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var groupName: String
    var connectionType: String
    var host: String
    var port: String
    var username: String
    var credentialID: String
    var notes: String
    var createdAt: Date
    
    static let storageKey = "terminal.device.cache.v3"
}

struct XNetTerminalSnippet: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var command: String
    var notes: String
    var sendReturn: Bool
    
    static let storageKey = "terminal.snippet.cache.v1"
}

struct XNetTerminalLog: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var connectionType: String
    var host: String
    var port: String
    var username: String
    var startedAt: Date
    var endedAt: Date
    var content: String
    
    var subtitle: String {
        let identity = username.isEmpty ? host : "\(username)@\(host)"
        return "\(connectionType) • \(identity):\(port)"
    }
    
    static let storageKey = "terminal.session.log.cache.v1"
}

struct TerminalDevicePayload: Codable {
    let name: String
    let groupName: String
    let connectionType: String
    let host: String
    let port: String
    let username: String
    let password: String
    let notes: String
}

struct TerminalSnippetPayload: Codable {
    let title: String
    let command: String
    let notes: String
    let sendReturn: Bool
}

struct XNetSystemBackup: Codable {
    let version: Int
    let exportedAt: Date
    let themeID: String
    let groups: [String]
    let devices: [XNetTerminalDevice]
    let snippets: [XNetTerminalSnippet]
}

// MARK: - NetBox Export DTOs
struct NetBoxSiteExport: Codable {
    let name: String
    let siteDescription: String
}
struct NetBoxVLANGroupExport: Codable {
    let name: String
    let groupDescription: String
    let minVID: Int
    let maxVID: Int
}
struct NetBoxVLANExport: Codable {
    let vid: Int
    let name: String
    let vlanDescription: String
    let status: String
    let siteName: String?
    let groupName: String?
}
struct NetBoxPrefixExport: Codable {
    let cidr: String
    let prefixDescription: String
    let siteName: String?
    let vlanVID: Int?
}
struct NetBoxDeviceExport: Codable {
    let name: String
    let deviceType: String
    let assetTag: String
    let notes: String
    let siteName: String?
}
struct NetBoxIPExport: Codable {
    let address: String
    let interfaceLabel: String
    let usageDescription: String
    let status: String
    let prefixCidr: String?
    let deviceName: String?
}

// MARK: - Legacy / Main Export System Update
struct XNetSystemBackupV2: Codable {
    let version: Int
    let exportedAt: Date
    let themeID: String
    
    // Legacy Terminal
    let groups: [String]
    let devices: [XNetTerminalDevice]
    let snippets: [XNetTerminalSnippet]
    let sessionLogs: [XNetTerminalLog]
    
    // NetBox Full Dump
    let netboxSites: [NetBoxSiteExport]?
    let netboxVlangroups: [NetBoxVLANGroupExport]?
    let netboxVlans: [NetBoxVLANExport]?
    let netboxPrefixes: [NetBoxPrefixExport]?
    let netboxDevices: [NetBoxDeviceExport]?
    let netboxIps: [NetBoxIPExport]?
}

enum TerminalDeviceGroupStore {
    static let storageKey = "terminal.group.cache.v1"
}

enum TerminalSnippetStore {
    static let storageKey = "terminal.snippet.cache.v1"
}

enum TerminalSessionLogStore {
    static let storageKey = "terminal.session.log.cache.v1"
}

enum TerminalPasswordStore {
    private static let keyPrefix = "br.com.myrouter.xnet.terminal.password."
    
    static func savePassword(_ password: String, credentialID: String) -> Bool {
        UserDefaults.standard.set(password, forKey: keyPrefix + credentialID)
        return true
    }
    
    static func readPassword(credentialID: String) -> String? {
        UserDefaults.standard.string(forKey: keyPrefix + credentialID)
    }
    
    static func deletePassword(credentialID: String) {
        UserDefaults.standard.removeObject(forKey: keyPrefix + credentialID)
    }
}
