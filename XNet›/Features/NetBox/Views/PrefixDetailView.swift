import SwiftUI
import SwiftData

struct PrefixDetailView: View {
    let prefix: NetBoxPrefix
    let devicesInSite: [NetBoxDevice]
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingAssign = false
    @State private var showingEdit = false
    @State private var showingDeviceSearch = false
    @State private var deviceSearchText = ""
    
    // Assignment States
    @State private var newIP = ""; @State private var label = "LAN"; @State private var usageType = "Device"; @State private var customUsage = ""; @State private var selectedDeviceID: PersistentIdentifier?
    
    // Edit States
    @State private var editCidr = ""; @State private var editDesc = ""
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // HEADER
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(prefix.cidr).font(.largeTitle).bold()
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Text(prefix.prefixDescription).font(.subheadline)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                    Spacer()
                    HStack {
                         Button("Edit Prefix") { editCidr = prefix.cidr; editDesc = prefix.prefixDescription; showingEdit = true }.buttonStyle(.plain).foregroundStyle(selectedTheme.accentColor)
                         Button { prepareAssignment(); showingAssign = true } label: { Label("Assign IP", systemImage: "plus.circle.fill") }.buttonStyle(.borderedProminent).tint(selectedTheme.accentColor)
                    }
                }
                
                let info = IPAMCalculator.getNetworkInfo(cidr: prefix.cidr)
                HStack(spacing: 20) {
                    CalcItem(label: "Gateway", value: info["Gateway"] ?? "-", theme: selectedTheme)
                    CalcItem(label: "Broadcast", value: info["Broadcast"] ?? "-", theme: selectedTheme)
                    CalcItem(label: "Hosts", value: info["Hosts"] ?? "-", theme: selectedTheme)
                }.padding(.top, 8)
            }
            .padding()
            .background(selectedTheme.cardBackgroundColor.opacity(0.4))
            
            Divider()
            
            // IP Allocation List
            List {
                if prefix.ips.isEmpty { 
                    ContentUnavailableView("No IP Allocations", systemImage: "network", description: Text("Start assigning IPs.")) 
                }
                ForEach(prefix.ips.sorted(by: { $0.address < $1.address })) { ip in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(ip.interfaceLabel ?? "LAN").font(.system(size: 8, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 4).background(selectedTheme.accentColor).cornerRadius(4)
                                Text(ip.address).font(.system(.body, design: .monospaced, weight: .semibold))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                            }
                            if let dev = ip.device { 
                                Label(dev.name, systemImage: "cpu").font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor) 
                            }
                        }
                        Spacer()
                        Button(role: .destructive) { modelContext.delete(ip); try? modelContext.save() } label: { Image(systemName: "trash").font(.caption) }.buttonStyle(.plain)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }.padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .alternatingRowBackgrounds(.disabled)
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
        // EDIT PREFIX SHEET
        .sheet(isPresented: $showingEdit) {
             VStack(spacing: 20) {
                  Text("Edit Prefix").font(.headline).foregroundStyle(selectedTheme.foregroundColor); 
                  Form { TextField("CIDR", text: $editCidr); TextField("Description", text: $editDesc) }
                  HStack { Button("Cancel") { showingEdit = false }; Spacer(); Button("Save") { prefix.cidr = editCidr; prefix.prefixDescription = editDesc; try? modelContext.save(); showingEdit = false }.buttonStyle(.borderedProminent).tint(selectedTheme.accentColor) }
             }.padding().frame(width: 320).background(selectedTheme.backgroundColor).cornerRadius(12)
        }
        // ASSIGN IP SHEET
        .sheet(isPresented: $showingAssign) {
            VStack(spacing: 20) {
                Text("Assign New IP").font(.headline).foregroundStyle(selectedTheme.foregroundColor)
                Form {
                    TextField("IP Address", text: $newIP); TextField("Interface", text: $label)
                    Picker("Target", selection: $usageType) { Text("Device").tag("Device"); Text("Manual").tag("Custom") }.pickerStyle(.segmented)
                    if usageType == "Device" {
                        Button { showingDeviceSearch = true } label: { HStack { Text(devicesInSite.first(where: { $0.id == selectedDeviceID })?.name ?? "Select Device..."); Spacer(); Image(systemName: "chevron.right").font(.caption) }.padding(8).background(selectedTheme.cardBackgroundColor.opacity(0.8)).cornerRadius(8) }.buttonStyle(.plain)
                        .popover(isPresented: $showingDeviceSearch) { DeviceSelector(devices: devicesInSite, searchText: $deviceSearchText, theme: selectedTheme) { dev in selectedDeviceID = dev.id; showingDeviceSearch = false }.frame(width: 300, height: 400) }
                    } else { TextField("Note", text: $customUsage) }
                }
                HStack { Button("Cancel") { showingAssign = false }; Spacer(); Button("Assign") { saveAssignment() }.buttonStyle(.borderedProminent).tint(selectedTheme.accentColor).disabled(newIP.isEmpty) }
            }.padding().frame(width: 350).background(selectedTheme.backgroundColor).cornerRadius(12)
        }
    }
    
    private func prepareAssignment() {
        if let lastIP = prefix.ips.sorted(by: { $0.address < $1.address }).last?.address {
            let parts = lastIP.split(separator: "."); if parts.count == 4, let last = Int(parts[3]) { newIP = "\(parts[0]).\(parts[1]).\(parts[2]).\(last + 1)" }
        } else { newIP = prefix.cidr.split(separator: "/").first?.description ?? "" }
    }
    
    private func saveAssignment() {
        if prefix.ips.contains(where: { $0.address == newIP }) { return }
        let device = (usageType == "Device") ? devicesInSite.first(where: { $0.id == selectedDeviceID }) : nil
        modelContext.insert(NetBoxIP(address: newIP, interfaceLabel: label, usageDescription: customUsage, prefix: prefix, device: device))
        try? modelContext.save(); showingAssign = false
    }
}

struct CalcItem: View {
    let label: String; let value: String; let theme: TerminalTheme
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased()).font(.system(size: 8, weight: .bold)).foregroundStyle(theme.mutedColor)
            Text(value).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundStyle(theme.accentColor)
        }
    }
}

struct DeviceSelector: View {
    let devices: [NetBoxDevice]; @Binding var searchText: String; let theme: TerminalTheme; let onSelect: (NetBoxDevice) -> Void
    var body: some View {
        VStack(spacing: 0) {
            TextField("Search devices...", text: $searchText).textFieldStyle(.roundedBorder).padding()
            List(devices.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }) { dev in
                Button { onSelect(dev) } label: { HStack { Image(systemName: "cpu").foregroundStyle(theme.accentColor); Text(dev.name).bold().foregroundStyle(theme.foregroundColor) } }.buttonStyle(.plain)
            }
            .scrollContentBackground(.hidden)
            .alternatingRowBackgrounds(.disabled)
            .background(theme.backgroundColor)
        }
    }
}
