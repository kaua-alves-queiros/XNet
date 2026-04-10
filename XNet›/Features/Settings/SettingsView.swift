import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct SettingsView: View {
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    @StateObject private var githubService = GitHubService()
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    
    // Data Management States
    @State private var showingDeviceImporter = false
    @State private var showingDeviceExporter = false
    @State private var exportDocument = TerminalDeviceRegistryDocument()
    @State private var importError: String?
    @State private var showingImportError = false
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configurações")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedTheme.foregroundColor)
                    Text("Personalize sua experiência no XNet Professional")
                        .font(.title3)
                        .foregroundStyle(selectedTheme.mutedColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 40)
                
                // Theme Selection Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Label("Aparência e Temas", systemImage: "paintpalette.fill")
                            .font(.headline)
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Spacer()
                        Text(selectedTheme.displayName)
                            .font(.caption.bold())
                            .foregroundStyle(selectedTheme.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(selectedTheme.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(TerminalTheme.allCases) { theme in
                                ThemeGridItem(theme: theme, isSelected: selectedThemeID == theme.rawValue, currentTheme: selectedTheme) {
                                    selectedThemeID = theme.rawValue
                                    TerminalThemeStore.saveThemeID(theme.rawValue)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                
                // App Information
                VStack(alignment: .leading, spacing: 20) {
                    Label("Sobre o XNet", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "number", title: "Versão", value: "2.5.0 (Pro)", theme: selectedTheme)
                        Divider().background(selectedTheme.panelBorderColor.opacity(0.2)).padding(.horizontal, 16)
                        SettingsRow(icon: "person.2.fill", title: "Desenvolvedor", value: "Kaua Alves Queiros", theme: selectedTheme)
                        Divider().background(selectedTheme.panelBorderColor.opacity(0.2)).padding(.horizontal, 16)
                        SettingsRow(icon: "shield.fill", title: "Licença", value: "MIT License", theme: selectedTheme)
                    }
                    .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                }
                
                // Developers Section (GitHub API)
                VStack(alignment: .leading, spacing: 20) {
                    Label("Equipe de Desenvolvimento", systemImage: "person.3.fill")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    if githubService.isFetching && githubService.contributors.isEmpty {
                        ProgressView()
                            .padding(.horizontal, 32)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(githubService.contributors) { contributor in
                                    Button {
                                        if let url = URL(string: contributor.htmlUrl) {
                                            openURL(url)
                                        }
                                    } label: {
                                        VStack(spacing: 12) {
                                            AsyncImage(url: URL(string: contributor.avatarUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Circle().fill(Color.gray.opacity(0.2))
                                            }
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(selectedTheme.accentColor.opacity(0.4), lineWidth: 1))
                                            
                                            VStack(spacing: 4) {
                                                Text(contributor.name ?? contributor.login)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(selectedTheme.foregroundColor)
                                                    .lineLimit(1)
                                                
                                                if let bio = contributor.bio, !bio.isEmpty {
                                                    Text(bio)
                                                        .font(.system(size: 10))
                                                        .foregroundStyle(selectedTheme.mutedColor)
                                                        .lineLimit(3)
                                                        .multilineTextAlignment(.center)
                                                }
                                                
                                                if let company = contributor.company, !company.isEmpty {
                                                    Text(company)
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundStyle(selectedTheme.accentColor)
                                                        .lineLimit(1)
                                                }
                                                
                                                Text("\(contributor.contributions) commits")
                                                    .font(.system(size: 9))
                                                    .padding(.top, 4)
                                                    .foregroundStyle(selectedTheme.mutedColor)
                                            }
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 10)
                                        .frame(width: 170)
                                        .background(selectedTheme.cardBackgroundColor.opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                }
                
                // Data Management Section
                VStack(alignment: .leading, spacing: 20) {
                    Label("Gerenciamento de Dados", systemImage: "square.and.arrow.up.on.square.fill")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 0) {
                        Button {
                            showingDeviceImporter = true
                        } label: {
                            SettingsRow(icon: "square.and.arrow.down", title: "Restaurar Backup Geral", value: "JSON", theme: selectedTheme)
                        }
                        .buttonStyle(.plain)
                        
                        Divider().background(selectedTheme.panelBorderColor.opacity(0.2)).padding(.horizontal, 16)
                        
                        Button {
                            prepareDeviceExport()
                        } label: {
                            SettingsRow(icon: "square.and.arrow.up", title: "Fazer Backup Geral (Exportar Tudo)", value: "JSON", theme: selectedTheme)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                }
                
                // Links Section
                VStack(alignment: .leading, spacing: 20) {
                    Label("Recursos Externos", systemImage: "link")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    // Official Website Link
                    Button {
                        if let url = URL(string: "https://xnet.cloud.queiros.com.br") {
                            openURL(url)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(selectedTheme.accentColor)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "safari.fill")
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Site Oficial & Documentação")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                Text("xnet.cloud.queiros.com.br")
                                    .font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(selectedTheme.mutedColor)
                        }
                        .padding(16)
                        .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                    
                    Button {
                        if let url = URL(string: "https://github.com/kaua-alves-queiros/XNet") {
                            openURL(url)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(selectedTheme.isLight ? Color.black : Color.white)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "terminal.fill") // Custom GitHub-like icon
                                    .foregroundStyle(selectedTheme.isLight ? Color.white : Color.black)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Repositório GitHub")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                Text("github.com/kaua-alves-queiros/XNet")
                                    .font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(selectedTheme.mutedColor)
                        }
                        .padding(16)
                        .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                }
                
                Spacer(minLength: 60)
            }
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                    endPoint: .bottom
            )
        )
        .onAppear {
            Task {
                await githubService.fetchContributors()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
        .fileImporter(
            isPresented: $showingDeviceImporter,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                importDevices(from: url)
            case .failure(let error):
                importError = error.localizedDescription
                showingImportError = true
            }
        }
        .fileExporter(
            isPresented: $showingDeviceExporter,
            document: exportDocument,
            contentType: UTType.json,
            defaultFilename: "XNet_Terminal_Export"
        ) { result in
            // Export handling if needed
        }
        .alert("Erro na Importação", isPresented: $showingImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = importError { Text(error) }
        }
    }
    
    // MARK: - Logic
    
    private func fetchAll<T: PersistentModel>(_ type: T.Type) -> [T] {
        let descriptor = FetchDescriptor<T>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func prepareDeviceExport() {
        let savedDevicesData = UserDefaults.standard.data(forKey: XNetTerminalDevice.storageKey)
        let savedGroupsData = UserDefaults.standard.data(forKey: TerminalDeviceGroupStore.storageKey)
        let savedSnippetsData = UserDefaults.standard.data(forKey: TerminalSnippetStore.storageKey)
        let savedLogsData = UserDefaults.standard.data(forKey: TerminalSessionLogStore.storageKey)
        
        let devices: [XNetTerminalDevice] = (try? JSONDecoder().decode([XNetTerminalDevice].self, from: savedDevicesData ?? Data())) ?? []
        let groups: [String] = (try? JSONDecoder().decode([String].self, from: savedGroupsData ?? Data())) ?? []
        let snippets: [XNetTerminalSnippet] = (try? JSONDecoder().decode([XNetTerminalSnippet].self, from: savedSnippetsData ?? Data())) ?? []
        let sessionLogs: [XNetTerminalLog] = (try? JSONDecoder().decode([XNetTerminalLog].self, from: savedLogsData ?? Data())) ?? []
        
        let sites = fetchAll(NetBoxSite.self).map { NetBoxSiteExport(name: $0.name, siteDescription: $0.siteDescription) }
        let vlanGroups = fetchAll(NetBoxVLANGroup.self).map { NetBoxVLANGroupExport(name: $0.name, groupDescription: $0.groupDescription, minVID: $0.minVID, maxVID: $0.maxVID) }
        let vlans = fetchAll(NetBoxVLAN.self).map { NetBoxVLANExport(vid: $0.vid, name: $0.name, vlanDescription: $0.vlanDescription, status: $0.status, siteName: $0.site?.name, groupName: $0.vlanGroup?.name) }
        let prefixes = fetchAll(NetBoxPrefix.self).map { NetBoxPrefixExport(cidr: $0.cidr, prefixDescription: $0.prefixDescription, siteName: $0.site?.name, vlanVID: $0.vlan?.vid) }
        let netDevices = fetchAll(NetBoxDevice.self).map { NetBoxDeviceExport(name: $0.name, deviceType: $0.deviceType, assetTag: $0.assetTag, notes: $0.notes, siteName: $0.site?.name) }
        let ips = fetchAll(NetBoxIP.self).map { NetBoxIPExport(address: $0.address, interfaceLabel: $0.interfaceLabel ?? "LAN", usageDescription: $0.usageDescription ?? "", status: $0.status ?? "Active", prefixCidr: $0.prefix?.cidr, deviceName: $0.device?.name) }
        
        let backup = XNetSystemBackupV2(
            version: 2,
            exportedAt: Date(),
            themeID: selectedThemeID,
            groups: groups,
            devices: devices,
            snippets: snippets,
            sessionLogs: sessionLogs,
            netboxSites: sites,
            netboxVlangroups: vlanGroups,
            netboxVlans: vlans,
            netboxPrefixes: prefixes,
            netboxDevices: netDevices,
            netboxIps: ips
        )
        
        if let data = try? JSONEncoder().encode(backup), let jsonString = String(data: data, encoding: .utf8) {
            exportDocument = TerminalDeviceRegistryDocument(text: jsonString)
            showingDeviceExporter = true
        }
    }
    
    private func importDevices(from url: URL) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Try V2 first, fallback to V1
            if let backupV2 = try? JSONDecoder().decode(XNetSystemBackupV2.self, from: data) {
                importLegacyDefaults(theme: backupV2.themeID, groups: backupV2.groups, devices: backupV2.devices, snippets: backupV2.snippets, logs: backupV2.sessionLogs)
                importNetBox(backupV2)
            } else if let backupV1 = try? JSONDecoder().decode(XNetSystemBackup.self, from: data) {
                importLegacyDefaults(theme: backupV1.themeID, groups: backupV1.groups, devices: backupV1.devices, snippets: backupV1.snippets, logs: [])
            } else {
                throw NSError(domain: "Format", code: -1, userInfo: [NSLocalizedDescriptionKey: "Formato incompatível."])
            }
            
            NotificationCenter.default.post(name: Notification.Name("TerminalDataReload"), object: nil)
        } catch {
            importError = "Formato de arquivo inválido ou versão de backup incompatível."
            showingImportError = true
        }
    }
    
    private func importLegacyDefaults(theme: String, groups: [String], devices: [XNetTerminalDevice], snippets: [XNetTerminalSnippet], logs: [XNetTerminalLog]) {
        selectedThemeID = theme
        TerminalThemeStore.saveThemeID(theme)
        
        // Merge Groups
        var currentGroups: [String] = (try? JSONDecoder().decode([String].self, from: UserDefaults.standard.data(forKey: TerminalDeviceGroupStore.storageKey) ?? Data())) ?? []
        for group in groups { if !currentGroups.contains(group) { currentGroups.append(group) } }
        if let gData = try? JSONEncoder().encode(currentGroups) { UserDefaults.standard.set(gData, forKey: TerminalDeviceGroupStore.storageKey) }
        
        // Merge Devices
        var currentDevices: [XNetTerminalDevice] = (try? JSONDecoder().decode([XNetTerminalDevice].self, from: UserDefaults.standard.data(forKey: XNetTerminalDevice.storageKey) ?? Data())) ?? []
        for imported in devices {
            if let existingIndex = currentDevices.firstIndex(where: { $0.id == imported.id || ($0.host == imported.host && $0.name == imported.name) }) {
                currentDevices[existingIndex] = imported
            } else { currentDevices.append(imported) }
        }
        if let dData = try? JSONEncoder().encode(currentDevices) { UserDefaults.standard.set(dData, forKey: XNetTerminalDevice.storageKey) }
        
        // Merge Snippets
        var currentSnippets: [XNetTerminalSnippet] = (try? JSONDecoder().decode([XNetTerminalSnippet].self, from: UserDefaults.standard.data(forKey: TerminalSnippetStore.storageKey) ?? Data())) ?? []
        for imported in snippets {
            if let existingIndex = currentSnippets.firstIndex(where: { $0.id == imported.id || $0.title == imported.title }) {
                currentSnippets[existingIndex] = imported
            } else { currentSnippets.append(imported) }
        }
        if let sData = try? JSONEncoder().encode(currentSnippets) { UserDefaults.standard.set(sData, forKey: TerminalSnippetStore.storageKey) }
        
        // Merge Session Logs
        if !logs.isEmpty {
            var currentLogs: [XNetTerminalLog] = (try? JSONDecoder().decode([XNetTerminalLog].self, from: UserDefaults.standard.data(forKey: TerminalSessionLogStore.storageKey) ?? Data())) ?? []
            for imported in logs {
                if !currentLogs.contains(where: { $0.id == imported.id }) { currentLogs.append(imported) }
            }
            if let lData = try? JSONEncoder().encode(currentLogs) { UserDefaults.standard.set(lData, forKey: TerminalSessionLogStore.storageKey) }
        }
    }
    
    private func importNetBox(_ backup: XNetSystemBackupV2) {
        let allSites: [NetBoxSite] = fetchAll(NetBoxSite.self)
        let allGroups: [NetBoxVLANGroup] = fetchAll(NetBoxVLANGroup.self)
        let allVlans: [NetBoxVLAN] = fetchAll(NetBoxVLAN.self)
        let allPrefixes: [NetBoxPrefix] = fetchAll(NetBoxPrefix.self)
        let allDevices: [NetBoxDevice] = fetchAll(NetBoxDevice.self)
        let allIPs: [NetBoxIP] = fetchAll(NetBoxIP.self)
        
        var siteDict = Dictionary(uniqueKeysWithValues: allSites.map { ($0.name, $0) })
        var groupDict = Dictionary(uniqueKeysWithValues: allGroups.map { ($0.name, $0) })
        var vlanDict = Dictionary(uniqueKeysWithValues: allVlans.map { ($0.vid, $0) })
        var prefixDict = Dictionary(uniqueKeysWithValues: allPrefixes.map { ($0.cidr, $0) })
        var deviceDict = Dictionary(uniqueKeysWithValues: allDevices.map { ($0.name, $0) })
        
        // 1. Sites
        if let sites = backup.netboxSites {
            for exp in sites {
                if siteDict[exp.name] == nil {
                    let newSite = NetBoxSite(name: exp.name, siteDescription: exp.siteDescription)
                    modelContext.insert(newSite)
                    siteDict[exp.name] = newSite
                }
            }
        }
        
        // 2. Groups
        if let vlg = backup.netboxVlangroups {
            for exp in vlg {
                if groupDict[exp.name] == nil {
                    let newGroup = NetBoxVLANGroup(name: exp.name, groupDescription: exp.groupDescription, minVID: exp.minVID, maxVID: exp.maxVID)
                    modelContext.insert(newGroup)
                    groupDict[exp.name] = newGroup
                }
            }
        }
        
        // 3. VLANs
        if let vlans = backup.netboxVlans {
            for exp in vlans {
                let site = exp.siteName != nil ? siteDict[exp.siteName!] : nil
                let grp = exp.groupName != nil ? groupDict[exp.groupName!] : nil
                if let existing = vlanDict[exp.vid] { existing.name = exp.name; existing.vlanDescription = exp.vlanDescription; existing.status = exp.status; existing.site = site; existing.vlanGroup = grp }
                else { let newV = NetBoxVLAN(vid: exp.vid, name: exp.name, vlanDescription: exp.vlanDescription, status: exp.status, site: site, vlanGroup: grp); modelContext.insert(newV); vlanDict[exp.vid] = newV }
            }
        }
        
        // 4. Prefixes
        if let prefs = backup.netboxPrefixes {
            for exp in prefs {
                let site = exp.siteName != nil ? siteDict[exp.siteName!] : nil
                let vlan = exp.vlanVID != nil ? vlanDict[exp.vlanVID!] : nil
                if let existing = prefixDict[exp.cidr] { existing.prefixDescription = exp.prefixDescription; existing.site = site; existing.vlan = vlan }
                else { let newP = NetBoxPrefix(cidr: exp.cidr, prefixDescription: exp.prefixDescription, site: site, vlan: vlan); modelContext.insert(newP); prefixDict[exp.cidr] = newP }
            }
        }
        
        // 5. Devices
        if let devs = backup.netboxDevices {
            for exp in devs {
                let site = exp.siteName != nil ? siteDict[exp.siteName!] : nil
                if let existing = deviceDict[exp.name] { existing.deviceType = exp.deviceType; existing.assetTag = exp.assetTag; existing.notes = exp.notes; existing.site = site }
                else { let newD = NetBoxDevice(name: exp.name, deviceType: exp.deviceType, assetTag: exp.assetTag, notes: exp.notes, site: site); modelContext.insert(newD); deviceDict[exp.name] = newD }
            }
        }
        
        // 6. IPs
        if let ips = backup.netboxIps {
            for exp in ips {
                let pref = exp.prefixCidr != nil ? prefixDict[exp.prefixCidr!] : nil
                let dev = exp.deviceName != nil ? deviceDict[exp.deviceName!] : nil
                if !allIPs.contains(where: { $0.address == exp.address }) {
                    modelContext.insert(NetBoxIP(address: exp.address, interfaceLabel: exp.interfaceLabel, usageDescription: exp.usageDescription, status: exp.status, prefix: pref, device: dev))
                }
            }
        }
        
        try? modelContext.save()
    }
}

struct ThemeGridItem: View {
    let theme: TerminalTheme
    let isSelected: Bool
    let currentTheme: TerminalTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Preview Box
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.backgroundColor)
                        .frame(height: 80)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.accentColor)
                            .frame(width: 40, height: 8)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.foregroundColor.opacity(0.6))
                            .frame(width: 60, height: 4)
                        HStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                Circle().fill(theme.mutedColor.opacity(0.4)).frame(width: 6, height: 6)
                            }
                        }
                    }
                    .padding(12)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? currentTheme.accentColor : currentTheme.foregroundColor)
                    Text(theme.appearanceLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(currentTheme.mutedColor)
                }
            }
            .padding(12)
            .frame(width: 140)
            .background(isSelected ? currentTheme.accentColor.opacity(0.12) : currentTheme.cardBackgroundColor.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? currentTheme.accentColor : currentTheme.panelBorderColor.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let theme: TerminalTheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(theme.foregroundColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.mutedColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
