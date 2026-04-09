import SwiftUI
import SwiftData

// MARK: - DASHBOARDS
struct NetBoxSitesDashboard: View {
    @Query(sort: \NetBoxSite.name) private var sites: [NetBoxSite]
    @Binding var selection: NetBoxView.NetBoxNavigationItem?
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        List {
            ForEach(sites) { site in
                Button { selection = .site(site.id) } label: {
                    VStack(alignment: .leading) {
                        Text(site.name).font(.headline).foregroundStyle(selectedTheme.foregroundColor)
                        Text("\(site.devices.count) Units • \(site.prefixes.count) Nets").font(.caption).foregroundStyle(selectedTheme.mutedColor)
                    }
                }.buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(sites[index])
                }
                try? modelContext.save()
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .scrollContentBackground(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct NetBoxAllDevicesView: View {
    let devices: [NetBoxDevice]
    @Binding var selection: NetBoxView.NetBoxNavigationItem?
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        List {
            ForEach(devices) { device in
                Button { selection = .device(device.id) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "cpu.fill").font(.title3).foregroundStyle(selectedTheme.accentColor.gradient)
                        VStack(alignment: .leading) { 
                            Text(device.name).font(.headline).foregroundStyle(selectedTheme.foregroundColor)
                            Text(device.site?.name ?? "Global Space").font(.caption).foregroundStyle(selectedTheme.mutedColor) 
                        }
                        Spacer()
                        Text(device.deviceType).font(.system(size: 9, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 6).padding(.vertical, 2).background(selectedTheme.accentColor).cornerRadius(4)
                    }.padding(.vertical, 4)
                }.buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(devices[index])
                }
                try? modelContext.save()
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .scrollContentBackground(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct NetBoxIPAMDashboard: View {
    @Query(sort: \NetBoxPrefix.cidr) private var allPrefixes: [NetBoxPrefix]
    @Binding var selection: NetBoxView.NetBoxNavigationItem?
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        List {
            ForEach(allPrefixes) { prefix in
                Button { selection = .prefix(prefix.id) } label: {
                    HStack {
                        VStack(alignment: .leading) { 
                            Text(prefix.cidr).font(.system(.body, design: .monospaced, weight: .bold)).foregroundStyle(selectedTheme.foregroundColor)
                            Text(prefix.site?.name ?? "Global").font(.caption2).foregroundStyle(selectedTheme.mutedColor) 
                        }
                        Spacer()
                        if let vlan = prefix.vlan { 
                            Text("VLAN \(vlan.vid)").font(.caption).foregroundStyle(selectedTheme.accentColor).padding(4).background(selectedTheme.accentColor.opacity(0.1)).cornerRadius(4) 
                        }
                    }
                }.buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(allPrefixes[index])
                }
                try? modelContext.save()
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .scrollContentBackground(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

struct NetBoxVLANsDashboard: View {
    let allVLANs: [NetBoxVLAN]
    @Query(sort: \NetBoxVLANGroup.name) private var allGroups: [NetBoxVLANGroup]
    @Binding var selection: NetBoxView.NetBoxNavigationItem?
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        List {
            ForEach(allGroups) { group in
                Section {
                    VLANMapList(group: group, allVLANs: allVLANs, selection: $selection, theme: selectedTheme)
                } header: {
                    Text("\(group.name) (\(group.minVID)-\(group.maxVID))")
                        .foregroundStyle(selectedTheme.mutedColor)
                }
            }
            if allGroups.isEmpty { 
                Section { 
                    VLANMapList(group: nil, allVLANs: allVLANs, selection: $selection, theme: selectedTheme) 
                } header: {
                    Text("Ungrouped Mapping")
                        .foregroundStyle(selectedTheme.mutedColor)
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .scrollContentBackground(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}

// MARK: - VLAN CALCULATIONS
struct VLANMapList: View {
    let group: NetBoxVLANGroup?; let allVLANs: [NetBoxVLAN]
    @Binding var selection: NetBoxView.NetBoxNavigationItem?
    let theme: TerminalTheme
    
    var body: some View {
        let min = group?.minVID ?? 1; let max = group?.maxVID ?? 4048
        let vlansInContext = allVLANs.filter { $0.vlanGroup?.id == group?.id }.sorted(by: { $0.vid < $1.vid })
        var rows: [VLANMapRow] = []; var lastID = min - 1
        for vlan in vlansInContext {
            if vlan.vid > lastID + 1 { rows.append(.available(id: "at-\(group?.id.hashValue ?? 0)-\(lastID+1)", start: lastID + 1, end: vlan.vid - 1)) }
            rows.append(.occupied(vlan: vlan)); lastID = vlan.vid
        }
        if lastID < max { rows.append(.available(id: "at-\(group?.id.hashValue ?? 0)-\(lastID+1)", start: lastID + 1, end: max)) }
        return ForEach(rows) { row in
            switch row {
            case .occupied(let v): 
                Button { selection = .vlan(v.id) } label: { 
                    HStack { 
                        Text("\(v.vid)").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(.white).padding(4).background(theme.accentColor).cornerRadius(4); 
                        Text(v.name).fontWeight(.medium).foregroundStyle(theme.foregroundColor) 
                    } 
                }.buttonStyle(.plain)
            case .available(_, let s, let e): 
                HStack { 
                    Image(systemName: "circle.fill").font(.system(size: 6)).foregroundStyle(.green); 
                    Text("Free (\(s==e ? "\(s)" : "\(s)-\(e)"))").font(.caption2).italic().foregroundStyle(theme.mutedColor); 
                    Spacer(); 
                    Text("FREE").font(.system(size: 8, weight: .bold)).foregroundStyle(.green).padding(.horizontal, 4).padding(.vertical, 1).overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.green, lineWidth: 0.5)) 
                }.padding(.leading, 8)
            }
        }
    }
}

enum VLANMapRow: Identifiable, Hashable {
    case occupied(vlan: NetBoxVLAN); case available(id: String, start: Int, end: Int)
    var id: String {
        switch self {
        case .occupied(let v): return "\(v.vid)-\(v.id.hashValue)"; case .available(let id, _, _): return id
        }
    }
}
