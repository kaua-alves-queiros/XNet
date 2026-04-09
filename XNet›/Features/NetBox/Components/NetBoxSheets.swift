import SwiftUI
import SwiftData

struct AddSiteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var name = ""; @State private var desc = ""
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Site Asset").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            Form { 
                TextField("Name", text: $name)
                TextField("Site Profile", text: $desc) 
            }
            HStack { 
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Generate") { 
                    if !name.isEmpty { 
                        modelContext.insert(NetBoxSite(name: name, siteDescription: desc))
                        try? modelContext.save() 
                    }
                    isPresented = false 
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .padding()
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct AddDeviceSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var name = ""; @State private var type = "Router"
    @Query private var allSites: [NetBoxSite]
    @State private var selectedSiteID: PersistentIdentifier?
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Provision Hardware").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            Form { 
                TextField("Hostname", text: $name)
                Picker("Location", selection: $selectedSiteID) { 
                    Text("None").tag(nil as PersistentIdentifier?)
                    ForEach(allSites) { s in Text(s.name).tag(s.id as PersistentIdentifier?) } 
                } 
            }
            HStack { 
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Provision") { 
                    if !name.isEmpty { 
                        let site = allSites.first(where: { $0.id == selectedSiteID })
                        modelContext.insert(NetBoxDevice(name: name, deviceType: type, site: site))
                        try? modelContext.save() 
                    }
                    isPresented = false 
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .padding()
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct AddPrefixSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var cidr = ""; @State private var desc = ""
    @Query private var allSites: [NetBoxSite]
    @State private var selectedSiteID: PersistentIdentifier?
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Reserve Subnet").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            Form { 
                TextField("CIDR (x.x.x.x/y)", text: $cidr)
                TextField("Description", text: $desc) 
            }
            HStack { 
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Reserve") { 
                    if !cidr.isEmpty { 
                        modelContext.insert(NetBoxPrefix(cidr: cidr, prefixDescription: desc, site: allSites.first(where: { $0.id == selectedSiteID })))
                        try? modelContext.save() 
                    }
                    isPresented = false 
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .padding()
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct AddVLANGroupSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var name = ""; @State private var min = "1"; @State private var max = "4094"
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Define VLAN Group").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            Form { 
                TextField("Group Name", text: $name)
                HStack { 
                    TextField("Min VID", text: $min)
                    TextField("Max VID", text: $max) 
                } 
            }
            HStack { 
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Register") { 
                    if !name.isEmpty { 
                        modelContext.insert(NetBoxVLANGroup(name: name, minVID: Int(min) ?? 1, maxVID: Int(max) ?? 4094))
                        try? modelContext.save() 
                    }
                    isPresented = false 
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .padding()
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct AddVLANSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var vid = "10"; @State private var name = ""
    @Query private var allGroups: [NetBoxVLANGroup]
    @State private var selectedGroupID: PersistentIdentifier?
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Configure Virtual LAN").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            Form { 
                TextField("VID #", text: $vid)
                TextField("VLAN Profile", text: $name)
                Picker("Scope Group", selection: $selectedGroupID) { 
                    Text("Ungrouped").tag(nil as PersistentIdentifier?)
                    ForEach(allGroups) { g in Text(g.name).tag(g.id as PersistentIdentifier?) } 
                } 
            }
            HStack { 
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Update") { 
                    if !name.isEmpty { 
                        modelContext.insert(NetBoxVLAN(vid: Int(vid) ?? 10, name: name, vlanGroup: allGroups.first(where: { $0.id == selectedGroupID })))
                        try? modelContext.save() 
                    }
                    isPresented = false 
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .padding()
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct QuickProvisionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var siteName = ""
    @State private var cidr = ""
    @State private var vlanID = "10"
    @State private var coreRouterName = ""
    @State private var gatewayIP = ""
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme { TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme }

    var body: some View {
        VStack(spacing: 20) {
            Text("Fast Deployment").font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            
            Text("Deploy an entire network infrastructure branch in seconds.")
                .font(.caption)
                .foregroundStyle(selectedTheme.mutedColor)
                .multilineTextAlignment(.center)
            
            Form {
                Section("Location & Prefix") {
                    TextField("Site Name (e.g. Branch SP)", text: $siteName)
                    TextField("Subnet CIDR (e.g. 192.168.1.0/24)", text: $cidr)
                }
                
                Section("Core Infrastructure") {
                    TextField("VLAN ID (e.g. 10)", text: $vlanID)
                    TextField("Main Switch/Router (e.g. RT-CORE)", text: $coreRouterName)
                    TextField("Gateway IP (e.g. 192.168.1.1)", text: $gatewayIP)
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Deploy Topology") {
                    provisionEnvironment()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .disabled(siteName.isEmpty || cidr.isEmpty || coreRouterName.isEmpty)
            }
        }
        .padding()
        .frame(width: 440, height: 480)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(12)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String { selectedThemeID = themeID }
            else { selectedThemeID = TerminalThemeStore.readThemeID() }
        }
    }
    
    private func provisionEnvironment() {
        let site = NetBoxSite(name: siteName, siteDescription: "Auto-provisioned via Fast Deployment")
        modelContext.insert(site)
        
        let prefix = NetBoxPrefix(cidr: cidr, prefixDescription: "\(siteName) Main Subnet", site: site)
        modelContext.insert(prefix)
        
        let device = NetBoxDevice(name: coreRouterName, deviceType: "Core Device", assetTag: "AUTO-\(Int.random(in: 1000...9999))", notes: "Core network equipment", site: site)
        modelContext.insert(device)
        
        var attachedVLAN: NetBoxVLAN? = nil
        if let vid = Int(vlanID), vid > 0 {
            let vlan = NetBoxVLAN(vid: vid, name: "VLAN \(vid) - \(siteName)", vlanDescription: "Management/Data VLAN", status: "Active", site: site, vlanGroup: nil)
            modelContext.insert(vlan)
            attachedVLAN = vlan
        }
        
        if !gatewayIP.isEmpty {
            let ip = NetBoxIP(address: gatewayIP, interfaceLabel: "VLAN\(vlanID) Int.", usageDescription: "Default Gateway", status: "Active", prefix: prefix, device: device)
            modelContext.insert(ip)
        }
        
        _ = attachedVLAN 
        
        try? modelContext.save()
    }
}
