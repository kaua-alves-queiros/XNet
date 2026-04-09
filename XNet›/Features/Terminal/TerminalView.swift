import SwiftUI
import UniformTypeIdentifiers

struct TerminalView: View {
    @State private var savedDevices: [XNetTerminalDevice] = []
    @State private var savedGroups: [String] = ["Geral"]
    
    @State private var connectionType: XNetTerminalConnectionType = .ssh
    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var username: String = ""
    @State private var savedPassword: String = ""
    @State private var manager: TerminalConnectionManager = TerminalConnectionManager()
    @State private var availableSerialPorts: [String] = []
    @State private var selectedDeviceID: UUID?
    @State private var showingDeviceForm: Bool = false
    @State private var showingGroupForm: Bool = false
    @State private var editingDevice: XNetTerminalDevice?
    @State private var isApplyingSavedDevice: Bool = false
    @State private var isDeviceListVisible: Bool = true
    @State private var tabs: [XNetTerminalTab] = []
    @State private var selectedTabID: UUID? = nil
    @State private var deviceSearch: String = ""
    @State private var expandedGroups: Set<String> = []
    @State private var selectedThemeID: String = TerminalThemeStore.readThemeID()
    @State private var savedSnippets: [XNetTerminalSnippet] = []
    @State private var savedSessionLogs: [XNetTerminalLog] = []
    @State private var snippetSearch: String = ""
    @State private var logSearch: String = ""
    @State private var showingSnippetLibrary: Bool = false
    @State private var showingLogHistory: Bool = false
    @State private var editingSnippet: XNetTerminalSnippet?
    @State private var sessionStartDates: [UUID: Date] = [:]
    @State private var persistedLogSignatures: [UUID: String] = [:]
    
    var body: some View {
        mainContent
            .navigationTitle("")
            .onAppear(perform: onAppear)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TerminalDataReload"))) { _ in
                reloadSavedDevices()
                reloadSavedGroups()
                refreshExpandedGroups()
            }
            .onChange(of: connectionType) { _, newValue in
                if !isApplyingSavedDevice { updateDefaultPort(for: newValue) }
                saveCurrentTabState()
            }
            .onChange(of: host) { _, _ in saveCurrentTabState() }
            .onChange(of: port) { _, _ in saveCurrentTabState() }
            .onChange(of: username) { _, _ in saveCurrentTabState() }
            .onChange(of: savedPassword) { _, _ in saveCurrentTabState() }
            .onChange(of: deviceSearch) { _, _ in refreshExpandedGroups() }
            .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
                if let themeID = output.object as? String { selectedThemeID = themeID }
                else { selectedThemeID = TerminalThemeStore.readThemeID() }
            }
            .onDisappear { persistLogIfNeeded(forTabID: selectedTabID) }
            .sheet(isPresented: $showingDeviceForm, content: deviceFormSheet)
            .sheet(isPresented: $showingGroupForm, content: groupFormSheet)
            .sheet(isPresented: $showingSnippetLibrary, content: snippetLibrarySheet)
            .sheet(isPresented: $showingLogHistory, content: logHistorySheet)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            topBarSection
            Divider()
            contentSection
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    @ViewBuilder
    private func deviceFormSheet() -> some View {
        TerminalDeviceFormSheet(deviceToEdit: editingDevice, availableGroups: formGroupOptions) { saveDevice($0) }
    }
    
    @ViewBuilder
    private func groupFormSheet() -> some View {
        TerminalDeviceGroupFormSheet { createGroup(named: $0) }
    }
    
    @ViewBuilder
    private func snippetLibrarySheet() -> some View {
        TerminalSnippetLibrarySheet(
            snippets: filteredSnippets,
            searchText: $snippetSearch,
            canSend: manager.isConnected,
            onAdd: { editingSnippet = nil },
            onEdit: { editingSnippet = $0 },
            onDelete: { deleteSnippet($0) },
            onSend: { sendSnippet($0) },
            onSave: { saveSnippet($0) },
            editingSnippet: editingSnippet
        )
    }
    
    @ViewBuilder
    private func logHistorySheet() -> some View {
        TerminalLogHistorySheet(
            logs: filteredSessionLogs,
            searchText: $logSearch,
            onDelete: { deleteLogEntry($0) },
            onClear: { clearSavedLogs() }
        )
    }
    
    private var topBarSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            tabBar
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shell Terminal")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedTheme.foregroundColor)
                    HStack(spacing: 8) {
                        Image(systemName: manager.isConnected ? "waveform.path.ecg" : "bolt.horizontal")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(manager.isConnected ? .green : selectedTheme.mutedColor)
                        Text(manager.isConnected ? "Sessão ativa via \(connectionType.rawValue)" : "Pronto para conectar")
                            .font(.subheadline)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                }
                Spacer()
                quickAccessBar
            }
                
            HStack(spacing: 8) {
                Group {
                    Button {
                        editingDevice = nil
                        showingDeviceForm = true
                    } label: { Image(systemName: "plus") }.help("Novo Dispositivo")
                    
                    Button {
                        showingGroupForm = true
                    } label: { Image(systemName: "folder.badge.plus") }.help("Nova Pasta")
                    
                    Divider().frame(height: 16).padding(.horizontal, 4)
                    
                    Button {
                        isDeviceListVisible.toggle()
                    } label: { Image(systemName: isDeviceListVisible ? "sidebar.left" : "sidebar.right") }.help("Alternar Lateral")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                Group {
                    Button {
                        editingSnippet = nil
                        showingSnippetLibrary = true
                    } label: { Image(systemName: "terminal.textbox") }.help("Snippets")
                    
                    Button {
                        showingLogHistory = true
                    } label: { Image(systemName: "clock.arrow.circlepath") }.help("Histórico de Logs")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var contentSection: some View {
        HStack(spacing: 0) {
            if isDeviceListVisible {
                TerminalSidebarView(
                    savedDevices: $savedDevices,
                    expandedGroups: $expandedGroups,
                    deviceSearch: $deviceSearch,
                    selectedDeviceID: $selectedDeviceID,
                    theme: selectedTheme,
                    groupedFilteredSavedDevices: groupedFilteredSavedDevices,
                    onToggleGroup: toggleGroup,
                    onEditDevice: { dev in
                        selectedDeviceID = dev.id
                        editingDevice = dev
                        showingDeviceForm = true
                    },
                    onConnectDevice: connectFromDevice,
                    onOpenNewTab: openDeviceInNewTab,
                    onDeleteDevice: deleteDevice,
                    onAddNewDevice: {
                        editingDevice = nil
                        showingDeviceForm = true
                    },
                    onAddNewGroup: { showingGroupForm = true }
                )
                
                Divider()
            }
            
            ZStack(alignment: .topLeading) {
                selectedTheme.backgroundColor
                
                if manager.isConnected {
                    InteractiveTerminalTextView(text: $manager.logs, theme: selectedTheme) { manager.sendRaw($0) }
                } else {
                    terminalPlaceholder
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedTheme.panelBorderColor.opacity(selectedTheme.isLight ? 0.65 : 0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(10)
        }
    }
    
    private var quickAccessBar: some View {
        HStack(spacing: 8) {
            Picker("", selection: $connectionType) {
                ForEach(XNetTerminalConnectionType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
            
            HStack(spacing: 6) {
                if connectionType == .serial {
                    Picker("Porta Serial", selection: $host) {
                        if availableSerialPorts.isEmpty { Text("Nenhuma porta").tag("") }
                        ForEach(availableSerialPorts, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                } else {
                    TextField("Host / IP", text: $host)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(selectedTheme.backgroundColor.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                TextField("Porta", text: $port)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(width: 60)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(selectedTheme.backgroundColor.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                if connectionType == .ssh {
                    TextField("Usuário", text: $username)
                        .textFieldStyle(.plain)
                        .background(selectedTheme.backgroundColor.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.system(size: 13)).padding(.horizontal, 10).padding(.vertical, 7)
                }
                
                if connectionType != .serial {
                    SecureField("Senha", text: $savedPassword)
                        .textFieldStyle(.plain)
                        .background(selectedTheme.backgroundColor.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.system(size: 13)).padding(.horizontal, 10).padding(.vertical, 7)
                }
                
                Button(action: toggleConnection) {
                    HStack(spacing: 6) {
                        Image(systemName: manager.isConnected ? "stop.fill" : "bolt.fill").font(.system(size: 11, weight: .bold))
                        Text(manager.isConnected ? "Desconectar" : "Conectar").font(.system(size: 12, weight: .bold))
                    }.frame(minWidth: 90)
                }
                .buttonStyle(.borderedProminent)
                .tint(manager.isConnected ? .red : selectedTheme.accentColor)
                .disabled(host.isEmpty && connectionType != .serial)
            }
            .padding(6)
            .background(selectedTheme.cardBackgroundColor.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    private var filteredSnippets: [XNetTerminalSnippet] {
        let term = snippetSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return savedSnippets.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } }
        return savedSnippets.filter { $0.title.localizedCaseInsensitiveContains(term) || $0.command.localizedCaseInsensitiveContains(term) }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
    
    private var filteredSessionLogs: [XNetTerminalLog] {
        let term = logSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return savedSessionLogs }
        return savedSessionLogs.filter { $0.title.localizedCaseInsensitiveContains(term) || $0.content.localizedCaseInsensitiveContains(term) }
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tabs) { (tab: XNetTerminalTab) in
                        HStack(spacing: 6) {
                            Button {
                                saveCurrentTabState()
                                selectedTabID = tab.id
                                loadTab(tab)
                            } label: {
                                HStack(spacing: 6) {
                                    Circle().fill(tab.manager.isConnected ? Color.green : Color.secondary.opacity(0.45)).frame(width: 7, height: 7)
                                    Text(tab.displayName).lineLimit(1).font(.system(size: 12, weight: .medium)).foregroundStyle(selectedTheme.foregroundColor)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(selectedTabID == tab.id ? selectedTheme.accentColor.opacity(0.2) : selectedTheme.cardBackgroundColor.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            
                            Button { closeTab(tab.id) } label: { Image(systemName: "xmark").font(.system(size: 10, weight: .semibold)).foregroundStyle(selectedTheme.mutedColor) }.buttonStyle(.plain)
                        }
                    }
                }
            }
            Button(action: addTab) { Label("Nova Aba", systemImage: "plus") }.buttonStyle(.bordered).controlSize(.small)
        }
        .padding(8).background(selectedTheme.cardBackgroundColor.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var terminalPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "powershell").font(.system(size: 40)).foregroundStyle(selectedTheme.foregroundColor.opacity(0.28))
            Text("Ready to connect...").font(.system(.body, design: .monospaced)).foregroundStyle(selectedTheme.foregroundColor.opacity(0.54))
        }
    }

    private func onAppear() {
        reloadSavedDevices()
        reloadSavedGroups()
        reloadSnippets()
        reloadSessionLogs()
        refreshExpandedGroups()
        if connectionType == .serial { availableSerialPorts = manager.getAvailableSerialPorts() }
    }

    private func saveCurrentTabState() {
        guard let sID = selectedTabID, let index = tabs.firstIndex(where: { $0.id == sID }) else { return }
        tabs[index].connectionType = connectionType
        tabs[index].host = host
        tabs[index].port = port
        tabs[index].username = username
        tabs[index].password = savedPassword
        tabs[index].availableSerialPorts = availableSerialPorts
        tabs[index].manager = manager
        tabs[index].sessionStartedAt = sessionStartDates[sID]
        tabs[index].persistedLogSignature = persistedLogSignatures[sID]
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedHost.isEmpty { tabs[index].name = trimmedHost }
    }
    
    private func loadTab(_ tab: XNetTerminalTab) {
        connectionType = tab.connectionType
        host = tab.host
        port = tab.port
        username = tab.username
        savedPassword = tab.password
        availableSerialPorts = tab.availableSerialPorts
        manager = tab.manager
        sessionStartDates[tab.id] = tab.sessionStartedAt
        persistedLogSignatures[tab.id] = tab.persistedLogSignature
    }
    
    private func addTab() {
        saveCurrentTabState()
        let tab = XNetTerminalTab(name: "Sessão \(tabs.count + 1)")
        tabs.append(tab)
        sessionStartDates[tab.id] = nil
        persistedLogSignatures[tab.id] = nil
        selectedTabID = tab.id
        loadTab(tab)
    }
    
    private func closeTab(_ id: UUID) {
        saveCurrentTabState()
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        persistLogIfNeeded(forTabID: id)
        tabs[index].manager.disconnect()
        tabs.remove(at: index)
        sessionStartDates.removeValue(forKey: id)
        persistedLogSignatures.removeValue(forKey: id)
        if tabs.isEmpty {
            selectedTabID = nil; manager = TerminalConnectionManager(); host = ""; port = "22"; username = ""; savedPassword = ""; availableSerialPorts = []
            return
        }
        if selectedTabID == id { let fallback = tabs[min(index, tabs.count - 1)]; selectedTabID = fallback.id; loadTab(fallback) }
    }
    
    private func updateDefaultPort(for type: XNetTerminalConnectionType) {
        switch type {
        case .ssh: port = "22"
        case .telnet: port = "23"
        case .serial:
            port = "115200"
            availableSerialPorts = manager.getAvailableSerialPorts()
            if let first = availableSerialPorts.first { host = first }
        }
    }
    
    private func toggleConnection() {
        if manager.isConnected { persistLogIfNeeded(forTabID: selectedTabID); manager.disconnect() }
        else { connectUsingCurrentFields() }
    }
    
    private func connectUsingCurrentFields() {
        ensureActiveTabForCurrentSession()
        persistLogIfNeeded(forTabID: selectedTabID)
        manager.logs = ""
        if let tabID = selectedTabID { sessionStartDates[tabID] = Date(); persistedLogSignatures[tabID] = nil }
        switch connectionType {
        case .ssh: manager.setSSHPassword(savedPassword); manager.connectSSH(host: host, port: port, user: username)
        case .telnet: manager.setTelnetPassword(savedPassword); manager.connectTelnet(host: host, port: port)
        case .serial: if let baud = Int(port) { manager.connectSerial(portPath: host, baudRate: baud) }
        }
    }
    
    private func ensureActiveTabForCurrentSession() {
        guard selectedTabID == nil else { return }
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let tab = XNetTerminalTab(name: trimmedHost.isEmpty ? "Sessão 1" : trimmedHost)
        tabs.append(tab)
        selectedTabID = tab.id
        sessionStartDates[tab.id] = nil; persistedLogSignatures[tab.id] = nil; saveCurrentTabState()
    }
    
    private func persistLogIfNeeded(forTabID tabID: UUID?) {
        guard let tID = tabID else { return }
        saveCurrentTabState()
        let activeTab = tabs.first(where: { $0.id == tID })
        let logSource: String = (selectedTabID == tID ? manager.logs : activeTab?.manager.logs) ?? ""
        let sanitized: String = logSource.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitized.isEmpty else { return }
        let signature = "\(activeTab?.connectionType.rawValue ?? connectionType.rawValue)|\(activeTab?.host ?? host)|\(sanitized.count)"
        if persistedLogSignatures[tID] == signature { return }
        let entry = XNetTerminalLog(id: UUID(), title: activeTab?.name ?? "Sessão", connectionType: activeTab?.connectionType.rawValue ?? connectionType.rawValue, host: activeTab?.host ?? host, port: activeTab?.port ?? port, username: activeTab?.username ?? username, startedAt: sessionStartDates[tID] ?? activeTab?.sessionStartedAt ?? Date(), endedAt: Date(), content: sanitized)
        savedSessionLogs.insert(entry, at: 0); if savedSessionLogs.count > 150 { savedSessionLogs = Array(savedSessionLogs.prefix(150)) }
        persistedLogSignatures[tID] = signature; if let index = tabs.firstIndex(where: { $0.id == tID }) { tabs[index].persistedLogSignature = signature; tabs[index].sessionStartedAt = sessionStartDates[tID] ?? Date() }
        persistSessionLogCache()
    }
    
    private var filteredSavedDevices: [XNetTerminalDevice] {
        let term = deviceSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return savedDevices }
        return savedDevices.filter { $0.name.localizedCaseInsensitiveContains(term) || $0.host.localizedCaseInsensitiveContains(term) }
    }
    
    private var groupedFilteredSavedDevices: [(group: String, devices: [XNetTerminalDevice])] {
        let grouped = Dictionary(grouping: filteredSavedDevices) { normalizedGroupName($0.groupName) }
        let groupNames = allGroupNames.filter { group in deviceSearch.isEmpty || group.localizedCaseInsensitiveContains(deviceSearch) || !(grouped[group] ?? []).isEmpty }
        return groupNames.map { (group: $0, devices: (grouped[$0] ?? []).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) }
    }
    
    private var allGroupNames: [String] {
        let merged = savedGroups + savedDevices.map { $0.groupName } + ["Geral"]
        var unique: [String] = []
        for name in merged.map({ normalizedGroupName($0) }) {
            if !unique.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) { unique.append(name) }
        }
        return unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    private var formGroupOptions: [String] {
        var options = allGroupNames
        if let editingDevice {
            let normalized = normalizedGroupName(editingDevice.groupName)
            if !options.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) { options.append(normalized) }
        }
        return options.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    private func applyDevice(_ device: XNetTerminalDevice) {
        isApplyingSavedDevice = true; connectionType = XNetTerminalConnectionType(rawValue: device.connectionType) ?? .ssh; host = device.host; port = device.port; username = device.username; savedPassword = resolvePassword(for: device)
        if connectionType == .serial { availableSerialPorts = manager.getAvailableSerialPorts(); if !availableSerialPorts.contains(host), !host.isEmpty { availableSerialPorts.insert(host, at: 0) } }
        DispatchQueue.main.async { isApplyingSavedDevice = false }
    }
    
    private func connectFromDevice(_ device: XNetTerminalDevice) {
        if manager.isConnected { manager.disconnect() }
        applyDevice(device); DispatchQueue.main.async { connectUsingCurrentFields() }
    }
    
    private func openDeviceInNewTab(_ device: XNetTerminalDevice) {
        saveCurrentTabState(); let newTab = XNetTerminalTab(name: device.name); tabs.append(newTab); selectedTabID = newTab.id; loadTab(newTab); applyDevice(device); connectUsingCurrentFields(); saveCurrentTabState()
    }
    
    private func normalizedGroupName(_ name: String) -> String { let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines); return trimmed.isEmpty ? "Geral" : trimmed }
    
    private func reloadSavedDevices() { guard let data = UserDefaults.standard.data(forKey: XNetTerminalDevice.storageKey), let cached = try? JSONDecoder().decode([XNetTerminalDevice].self, from: data) else { return }; savedDevices = cached }
    private func reloadSavedGroups() { guard let data = UserDefaults.standard.data(forKey: TerminalDeviceGroupStore.storageKey), let cached = try? JSONDecoder().decode([String].self, from: data) else { return }; savedGroups = cached }
    private func reloadSnippets() { guard let data = UserDefaults.standard.data(forKey: TerminalSnippetStore.storageKey), let cached = try? JSONDecoder().decode([XNetTerminalSnippet].self, from: data) else { return }; savedSnippets = cached }
    private func reloadSessionLogs() { guard let data = UserDefaults.standard.data(forKey: TerminalSessionLogStore.storageKey), let cached = try? JSONDecoder().decode([XNetTerminalLog].self, from: data) else { return }; savedSessionLogs = cached }
    
    private func saveDevice(_ payload: TerminalDevicePayload) {
        let entry = XNetTerminalDevice(id: editingDevice?.id ?? UUID(), name: payload.name, groupName: payload.groupName, connectionType: payload.connectionType, host: payload.host, port: payload.port, username: payload.username, credentialID: "", notes: payload.notes, createdAt: editingDevice?.createdAt ?? Date())
        _ = TerminalPasswordStore.savePassword(payload.password, credentialID: normalizedCredentialID(for: entry))
        if let index = savedDevices.firstIndex(where: { $0.id == entry.id }) { savedDevices[index] = entry } else { savedDevices.append(entry) }
        persistDevicesCache()
    }
    
    private func createGroup(named name: String) { let normalized = normalizedGroupName(name); if !savedGroups.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) { savedGroups.append(normalized); persistGroupsCache() } }
    private func deleteDevice(_ device: XNetTerminalDevice) { savedDevices.removeAll(where: { $0.id == device.id }); persistDevicesCache(); TerminalPasswordStore.deletePassword(credentialID: normalizedCredentialID(for: device)) }
    
    private func saveSnippet(_ payload: TerminalSnippetPayload) {
        let entry = XNetTerminalSnippet(id: editingSnippet?.id ?? UUID(), title: payload.title, command: payload.command, notes: payload.notes, sendReturn: payload.sendReturn)
        if let index = savedSnippets.firstIndex(where: { $0.id == entry.id }) { savedSnippets[index] = entry } else { savedSnippets.append(entry) }
        persistSnippetCache()
    }
    
    private func deleteSnippet(_ snippet: XNetTerminalSnippet) { savedSnippets.removeAll(where: { $0.id == snippet.id }); persistSnippetCache() }
    private func sendSnippet(_ snippet: XNetTerminalSnippet) { var cmd = snippet.command; if snippet.sendReturn && !cmd.hasSuffix("\n") { cmd += "\n" }; manager.sendRaw(cmd) }
    private func deleteLogEntry(_ entry: XNetTerminalLog) { savedSessionLogs.removeAll(where: { $0.id == entry.id }); persistSessionLogCache() }
    private func clearSavedLogs() { savedSessionLogs = []; persistSessionLogCache() }
    
    private func persistDevicesCache() { if let data = try? JSONEncoder().encode(savedDevices) { UserDefaults.standard.set(data, forKey: XNetTerminalDevice.storageKey) } }
    private func persistGroupsCache() { if let data = try? JSONEncoder().encode(savedGroups) { UserDefaults.standard.set(data, forKey: TerminalDeviceGroupStore.storageKey) } }
    private func persistSnippetCache() { if let data = try? JSONEncoder().encode(savedSnippets) { UserDefaults.standard.set(data, forKey: TerminalSnippetStore.storageKey) } }
    private func persistSessionLogCache() { if let data = try? JSONEncoder().encode(savedSessionLogs) { UserDefaults.standard.set(data, forKey: TerminalSessionLogStore.storageKey) } }
    
    private func toggleGroup(_ group: String) { if expandedGroups.contains(group) { expandedGroups.remove(group) } else { expandedGroups.insert(group) } }
    private func refreshExpandedGroups() { let available = Set(groupedFilteredSavedDevices.map { $0.group }); if available.isEmpty { expandedGroups = []; return }; if expandedGroups.isEmpty { expandedGroups = available; return }; expandedGroups = expandedGroups.intersection(available); if expandedGroups.isEmpty { expandedGroups = available } }
    
    private func normalizedCredentialID(for entry: XNetTerminalDevice) -> String { let trimmed = entry.credentialID.trimmingCharacters(in: .whitespacesAndNewlines); return trimmed.isEmpty ? "\(entry.connectionType)|\(entry.host)|\(entry.port)|\(entry.username)" : trimmed }
    
    private func resolvePassword(for entry: XNetTerminalDevice) -> String {
        let pID = normalizedCredentialID(for: entry)
        for cID in credentialCandidates(for: entry) {
            guard let pass = TerminalPasswordStore.readPassword(credentialID: cID), !pass.isEmpty else { continue }
            if cID != pID { _ = TerminalPasswordStore.savePassword(pass, credentialID: pID) }
            return pass
        }
        return ""
    }
    
    private func credentialCandidates(for e: XNetTerminalDevice) -> [String] {
        let pID = normalizedCredentialID(for: e)
        let candidates = [pID, "\(e.connectionType)|\(e.host)|\(e.port)|\(e.username)", "\(e.host)|\(e.port)|\(e.username)", "\(e.host)|\(e.username)", "\(e.host.lowercased())|\(e.username)"]
        var unique: [String] = []
        for c in candidates { let v = c.trimmingCharacters(in: .whitespacesAndNewlines); if !v.isEmpty && !unique.contains(v) { unique.append(v) } }
        return unique
    }
}
