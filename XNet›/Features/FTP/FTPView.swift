//
//  FTPView.swift
//  XNet›
//

import SwiftUI
import UniformTypeIdentifiers

struct FTPView: View {
    @State private var connectionManager = FTPConnectionManager()
    
    // Connection Settings
    @State private var host = ""
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var isSFTP = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Configuration Bar
            VStack(spacing: 12) {
                HStack {
                    Text("File Transfer (FTP/SFTP)")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Picker("Protocol", selection: $isSFTP) {
                        Text("SFTP").tag(true)
                        Text("FTP").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    .onChange(of: isSFTP) { _, newSFTP in
                        port = newSFTP ? "22" : "21"
                    }
                    
                    TextField("Host", text: $host)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Port", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                    
                    Button(action: toggleConnection) {
                        Text(connectionManager.isConnected ? "Disconnect" : "Connect")
                            .frame(width: 80)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(connectionManager.isConnected ? .red : .blue)
                    .disabled(host.isEmpty)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Dual Pane View
            GeometryReader { geo in
                HStack(spacing: 0) {
                    // LEFT: Local Files
                    LocalFileBrowser(manager: connectionManager)
                        .frame(width: geo.size.width / 2)
                    
                    Divider()
                    
                    // RIGHT: Remote Files
                    RemoteFileBrowser(manager: connectionManager)
                        .frame(width: geo.size.width / 2)
                }
            }
            
            // Transfer Status Bar
            Divider()
            HStack {
                Text(connectionManager.statusMessage)
                    .font(.caption)
                    .foregroundColor(connectionManager.isTransferring ? .blue : .secondary)
                
                Spacer()
                
                if connectionManager.isTransferring {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .navigationTitle("FTP / SFTP")
    }
    
    private func toggleConnection() {
        if connectionManager.isConnected {
            connectionManager.disconnect()
        } else {
            connectionManager.connect(host: host, port: port, user: username, pass: password, isSFTP: isSFTP)
        }
    }
}

// MARK: - Models

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let size: Int64
    let path: String
    let date: Date
}

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case date = "Date"
    var id: String { self.rawValue }
}

// MARK: - Local Browser

struct LocalFileBrowser: View {
    @Bindable var manager: FTPConnectionManager
    @State private var currentPath: String = NSHomeDirectory()
    @State private var files: [FileItem] = []
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .name
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Local Site:")
                    .bold()
                TextField("", text: $currentPath)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { loadFiles() }
                
                Button(action: {
                    let url = URL(fileURLWithPath: currentPath)
                    currentPath = url.deletingLastPathComponent().path
                    loadFiles()
                }) {
                    Image(systemName: "arrow.up.doc")
                }
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                TextField("Filter files...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Picker("", selection: $sortOption) {
                    ForEach(SortOption.allCases) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
                .frame(width: 80)
            }
            .padding(6)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            let filteredFiles = searchText.isEmpty ? files : files.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            let sortedFiles = filteredFiles.sorted {
                if $0.isDirectory != $1.isDirectory { return $0.isDirectory && !$1.isDirectory }
                if sortOption == .date {
                    return $0.date > $1.date // Newest first
                } else {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            List {
                ForEach(sortedFiles) { file in
                    HStack {
                        Image(systemName: file.isDirectory ? "folder.fill" : "doc")
                            .foregroundColor(file.isDirectory ? .blue : .secondary)
                        Text(file.name)
                        Spacer()
                        if !file.isDirectory {
                            Text(formatBytes(file.size))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if file.date != Date.distantPast {
                            Text(formatDate(file.date))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onItemDoubleClick {
                        if file.isDirectory {
                            currentPath = file.path
                            loadFiles()
                        }
                    }
                    // Implement Drag out (Upload)
                    .onDrag {
                        let provider = NSItemProvider(object: file.path as NSString)
                        provider.suggestedName = "UPLOAD:\(file.path)"
                        return provider
                    }
                }
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers in
                // Accept drop from right side (Download)
                providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                    if let stringData = item as? Data, let path = String(data: stringData, encoding: .utf8), path.starts(with: "DOWNLOAD:") {
                        let remotePath = String(path.dropFirst(9))
                        DispatchQueue.main.async {
                            manager.downloadFile(remotePath: remotePath, localFolder: currentPath)
                        }
                    }
                }
                return true
            }
        }
        .onAppear { loadFiles() }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocalBrowserRefresh"))) { _ in
            loadFiles()
        }
    }
    
    private func loadFiles() {
        let fm = FileManager.default
        do {
            let contents = try fm.contentsOfDirectory(atPath: currentPath)
            var items: [FileItem] = []
            
            for item in contents {
                if item.hasPrefix(".") { continue } // simple skip hidden
                let fullPath = (currentPath as NSString).appendingPathComponent(item)
                var isDir: ObjCBool = false
                if fm.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    let attrs = try? fm.attributesOfItem(atPath: fullPath)
                    let size = attrs?[.size] as? Int64 ?? 0
                    let date = attrs?[.modificationDate] as? Date ?? Date.distantPast
                    items.append(FileItem(name: item, isDirectory: isDir.boolValue, size: size, path: fullPath, date: date))
                }
            }
            
            // Sort dirs first
            files = items.sorted {
                if $0.isDirectory == $1.isDirectory { return $0.name.lowercased() < $1.name.lowercased() }
                return $0.isDirectory && !$1.isDirectory
            }
        } catch {
            print("Local list error: \(error)")
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Remote Browser

struct RemoteFileBrowser: View {
    @Bindable var manager: FTPConnectionManager
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .name
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Remote Site:")
                    .bold()
                TextField("", text: $manager.remoteCurrentPath)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { manager.loadRemoteFiles() }
                    .disabled(!manager.isConnected)
                
                Button(action: {
                    let path = manager.remoteCurrentPath
                    var parts = path.split(separator: "/")
                    if !parts.isEmpty {
                        parts.removeLast()
                        manager.remoteCurrentPath = parts.isEmpty ? "/" : "/" + parts.joined(separator: "/")
                        manager.loadRemoteFiles()
                    }
                }) {
                    Image(systemName: "arrow.up.doc")
                }
                .disabled(!manager.isConnected)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                TextField("Filter files...", text: $searchText)
                    .textFieldStyle(.plain)
                    .disabled(!manager.isConnected)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Picker("", selection: $sortOption) {
                    ForEach(SortOption.allCases) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
                .disabled(!manager.isConnected)
                .frame(width: 80)
            }
            .padding(6)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            if !manager.isConnected {
                VStack {
                    Spacer()
                    Text("Not Connected")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                let filteredFiles = searchText.isEmpty ? manager.remoteFiles : manager.remoteFiles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                let sortedFiles = filteredFiles.sorted {
                    if $0.isDirectory != $1.isDirectory { return $0.isDirectory && !$1.isDirectory }
                    if sortOption == .date {
                        return $0.date > $1.date
                    } else {
                        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                }
                List {
                    ForEach(sortedFiles) { file in
                        HStack {
                            Image(systemName: file.isDirectory ? "folder.fill" : "doc")
                                .foregroundColor(file.isDirectory ? .blue : .secondary)
                            Text(file.name)
                            Spacer()
                            if !file.isDirectory {
                                Text(formatBytes(file.size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if file.date != Date.distantPast {
                                Text(formatDate(file.date))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onItemDoubleClick {
                            if file.isDirectory {
                                manager.remoteCurrentPath = file.path
                                manager.loadRemoteFiles()
                            }
                        }
                        // Implement Drag out (Download)
                        .onDrag {
                            let dragData = "DOWNLOAD:\(file.path)".data(using: .utf8)!
                            let provider = NSItemProvider(item: dragData as NSData, typeIdentifier: UTType.plainText.identifier)
                            return provider
                        }
                    }
                }
                .onDrop(of: [.plainText], isTargeted: nil) { providers in
                    // Accept drop from left side (Upload)
                    providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                        // It might come as a string or data or URL
                        if let str = item as? String, str.starts(with: "UPLOAD:") {
                            let localPath = String(str.dropFirst(7))
                            DispatchQueue.main.async {
                                manager.uploadFile(localPath: localPath, remoteFolder: manager.remoteCurrentPath)
                            }
                        } else if let data = item as? Data, let str = String(data: data, encoding: .utf8), str.starts(with: "UPLOAD:") {
                            let localPath = String(str.dropFirst(7))
                            DispatchQueue.main.async {
                                manager.uploadFile(localPath: localPath, remoteFolder: manager.remoteCurrentPath)
                            }
                        }
                    }
                    return true
                }
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Helper for double click on macOS lists (Requires custom modifier since List row actions are tricky in SwiftUI macOS)
extension View {
    func onItemDoubleClick(action: @escaping () -> Void) -> some View {
        self.onTapGesture(count: 2, perform: action)
    }
}
