import SwiftUI
import SwiftData

struct IPScanView: View {
    @State private var ipScanner = IPScannerService()
    @State private var subnet: String = "192.168.1.0/24"
    @State private var scannedDevices: [ScannedDevice] = []
    @State private var isScanning = false
    @State private var currentTask: Task<Void, Never>? = nil
    @State private var statusText: String = "Enter IP range (e.g. 192.168.1.0/24 or 8.8.8.1-8.8.8.10)"
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDeviceToDocument: ScannedDevice? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // High-End Header
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Network Discovery")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if isScanning {
                            ProgressView()
                                .controlSize(.small)
                        }
                        
                        Button(action: {
                            if isScanning { stopScan() } else { startScan() }
                        }) {
                            HStack {
                                Image(systemName: isScanning ? "stop.fill" : "play.fill")
                                Text(isScanning ? "Stop" : "Start Scan")
                            }
                            .frame(width: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(isScanning ? .red : selectedTheme.accentColor)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                
                // Search & Input Bar
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14, weight: .bold))
                        
                        TextField("Subnet (e.g., 192.168.1.0/24)", text: $subnet)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(selectedTheme.cardBackgroundColor.opacity(selectedTheme.isLight ? 0.94 : 0.6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedTheme.panelBorderColor.opacity(0.35), lineWidth: 1)
                    )
                    .disabled(isScanning)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: { scannedDevices.removeAll() }) {
                        Image(systemName: "broom.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("Clear Results")
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 24)

            // Modern Results Table
            Table(scannedDevices) {
                TableColumn("Node Status") { device in
                    HStack {
                        Circle()
                            .fill(device.isOnline ? .green : .red)
                            .frame(width: 8, height: 8)
                        Text(device.ip)
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .foregroundStyle(device.isOnline ? selectedTheme.foregroundColor : selectedTheme.mutedColor)
                    }
                }
                .width(160)
                
                TableColumn("Physical Address") { device in
                    Text(device.mac)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(device.isOnline ? selectedTheme.mutedColor : selectedTheme.mutedColor.opacity(0.5))
                }
                .width(180)
                
                TableColumn("Manufacturer") { device in
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .font(.caption)
                            .foregroundStyle(device.isOnline ? selectedTheme.accentColor.opacity(0.7) : selectedTheme.mutedColor.opacity(0.3))
                        Text(device.vendor)
                            .foregroundStyle(device.isOnline ? selectedTheme.foregroundColor : selectedTheme.mutedColor)
                    }
                }
                
                TableColumn("Hostname") { device in
                    Text(device.hostname)
                        .italic()
                        .foregroundStyle(selectedTheme.mutedColor.opacity(0.8))
                        .lineLimit(1)
                }
                
                TableColumn("Doc.") { device in
                    Button {
                        selectedDeviceToDocument = device
                    } label: {
                        Image(systemName: "doc.badge.plus")
                            .foregroundStyle(device.isOnline ? selectedTheme.accentColor : selectedTheme.mutedColor.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .help("Document this device in NetBox")
                    .disabled(!device.isOnline)
                }
                .width(40)
            }
            .tableStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(item: $selectedDeviceToDocument) { device in
            QuickDocumentSheet(device: device)
                .frame(width: 400, height: 420)
        }
        .navigationTitle("IP Discovery")
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
        .onDisappear {
            stopScan()
        }
    }
    
    private func startScan() {
        scannedDevices.removeAll()
        isScanning = true
        statusText = "Scanning \(subnet)..."
        
        let targets = IPScannerService.parseInput(subnet)
        scannedDevices = targets.map { ScannedDevice(ip: $0, mac: "N/A", hostname: "-", vendor: "-", isOnline: false) }
        
        scannedDevices.sort { dev1, dev2 in
            let parts1 = dev1.ip.split(separator: ".").compactMap { Int($0) }
            let parts2 = dev2.ip.split(separator: ".").compactMap { Int($0) }
            for i in 0..<min(parts1.count, parts2.count) {
                if parts1[i] != parts2[i] { return parts1[i] < parts2[i] }
            }
            return parts1.count < parts2.count
        }
        
        currentTask = Task {
            let stream = ipScanner.scan(subnet: subnet)
            var buffer: [ScannedDevice] = []
            var lastUpdate = Date()
            
            for await device in stream {
                if Task.isCancelled { break }
                buffer.append(device)
                
                if buffer.count >= 10 || Date().timeIntervalSince(lastUpdate) > 0.25 {
                    for updatedDevice in buffer {
                        if let idx = scannedDevices.firstIndex(where: { $0.ip == updatedDevice.ip }) {
                            scannedDevices[idx] = updatedDevice
                        } else {
                            scannedDevices.append(updatedDevice)
                        }
                    }
                    
                    buffer.removeAll()
                    lastUpdate = Date()
                }
            }
            
            if !buffer.isEmpty {
                for updatedDevice in buffer {
                    if let idx = scannedDevices.firstIndex(where: { $0.ip == updatedDevice.ip }) {
                        scannedDevices[idx] = updatedDevice
                    } else {
                        scannedDevices.append(updatedDevice)
                    }
                }
            }
            
            isScanning = false
            let liveCount = scannedDevices.filter({ $0.isOnline }).count
            statusText = "Scan Complete. Found \(liveCount) live devices out of \(targets.count)."
        }
    }
    
    private func stopScan() {
        currentTask?.cancel()
        currentTask = nil
        isScanning = false
        statusText = "Scan stopped."
    }
}

struct QuickDocumentSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let device: ScannedDevice
    
    var theme: TerminalTheme {
        TerminalTheme(rawValue: TerminalThemeStore.readThemeID()) ?? .defaultTheme
    }
    
    @State private var name: String = ""
    @State private var type: String = "Network Device"
    @State private var notes: String = ""
    @Query private var sites: [NetBoxSite]
    @State private var selectedSiteID: PersistentIdentifier?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Document")
                        .font(.headline)
                        .foregroundStyle(theme.foregroundColor)
                    Text("Pre-configuration snapshot for \(device.ip)")
                        .font(.caption)
                        .foregroundStyle(theme.mutedColor)
                }
                Spacer()
                Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(theme.mutedColor) }.buttonStyle(.plain)
            }
            .padding()
            .background(theme.chromeTopColor)
            
            Form {
                Section("Identity") {
                    TextField("Device Name", text: $name)
                    TextField("Device Type", text: $type)
                }
                
                Section("Diagnostic Notes (Draft Configuration)") {
                    TextEditor(text: $notes)
                        .frame(height: 120)
                        .font(.system(.body, design: .monospaced))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
                
                Section("Metadata") {
                    Picker("Inventory Site", selection: $selectedSiteID) {
                        Text("Global / Default").tag(nil as PersistentIdentifier?)
                        ForEach(sites) { site in
                            Text(site.name).tag(site.id as PersistentIdentifier?)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save Documentation") {
                    save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear {
            name = device.hostname.isEmpty ? "Device-\(device.ip.split(separator: ".").last ?? "")" : device.hostname
            type = device.vendor.isEmpty ? "Network Node" : device.vendor
            notes = "// Snapshot: \(Date().formatted())\n// Discovered MAC: \(device.mac)\n// Initial Discovery Stats: \n\n"
        }
    }
    
    private func save() {
        let site = sites.first(where: { $0.id == selectedSiteID })
        let newDevice = NetBoxDevice(name: name, deviceType: type, notes: notes, site: site)
        modelContext.insert(newDevice)
        
        // Save the discovered IP
        let newIP = NetBoxIP(address: device.ip, device: newDevice)
        modelContext.insert(newIP)
        
        try? modelContext.save()
    }
}
