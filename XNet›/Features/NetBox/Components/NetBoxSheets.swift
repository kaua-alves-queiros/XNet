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
