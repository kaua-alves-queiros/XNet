import SwiftUI
import SwiftData

struct NetBoxView: View {
    @Environment(\.modelContext) private var modelContext
    
    enum NetBoxNavigationItem: Hashable {
        case allSites, allDevices, ipam, vlans
        case site(PersistentIdentifier), vlan(PersistentIdentifier), prefix(PersistentIdentifier), group(PersistentIdentifier), device(PersistentIdentifier)
    }
    
    @Query(sort: \NetBoxSite.name) private var allSites: [NetBoxSite]
    @Query(sort: \NetBoxDevice.name) private var allDevices: [NetBoxDevice]
    @Query(sort: \NetBoxPrefix.cidr) private var allPrefixes: [NetBoxPrefix]
    
    @State private var showingEraseConfirmation = false
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Dashboard Header
                HeaderView(title: "NetBox Audit", subtitle: "Infrastructure and IPAM Management", theme: selectedTheme)
                
                // Asset Overview Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: 20) {
                    AssetCard(title: "Deployment Sites", count: allSites.count, icon: "building.2.fill", color: .purple, theme: selectedTheme)
                    AssetCard(title: "Total Devices", count: allDevices.count, icon: "cpu.fill", color: .blue, theme: selectedTheme)
                    AssetCard(title: "IP Prefixes", count: allPrefixes.count, icon: "network", color: .green, theme: selectedTheme)
                }
                
                // Detailed Breakdown Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Infrastructure Health")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(selectedTheme.foregroundColor)
                    
                    HStack(spacing: 20) {
                        QuickMetric(title: "Active VLANs", value: "14", trend: "+2 this week", theme: selectedTheme)
                        QuickMetric(title: "Usage (L3)", value: "62%", trend: "Stable", theme: selectedTheme)
                        QuickMetric(title: "Rack Units", value: "24U Used", trend: "4U Free", theme: selectedTheme)
                    }
                }
                
                // Administration Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Administration")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(selectedTheme.foregroundColor)
                    
                    Button(role: .destructive) {
                        showingEraseConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.slash.fill")
                            Text("Erase NetBox Environment")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15))
                        .foregroundStyle(.red)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
        }
        .scrollContentBackground(.hidden)
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
        .alert("Erase Entire Environment?", isPresented: $showingEraseConfirmation) {
            Button("Erase All Data", role: .destructive) {
                purgeNetBox()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all NetBox objects (Sites, Devices, VLANs, Prefixes, and IPs) from your local SwiftData store. Terminal snippets and SSH connections will NOT be affected.")
        }
    }
    
    private func purgeNetBox() {
        do {
            try modelContext.delete(model: NetBoxSite.self)
            try modelContext.delete(model: NetBoxVLANGroup.self)
            try modelContext.delete(model: NetBoxVLAN.self)
            try modelContext.delete(model: NetBoxPrefix.self)
            try modelContext.delete(model: NetBoxDevice.self)
            try modelContext.delete(model: NetBoxIP.self)
            try modelContext.save()
        } catch {
            print("Failed to purge NetBox env: \(error)")
        }
    }
}

struct HeaderView: View {
    let title: String
    let subtitle: String
    let theme: TerminalTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(theme.foregroundColor)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(theme.mutedColor)
        }
    }
}

struct AssetCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let theme: TerminalTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill")
                    .foregroundStyle(theme.mutedColor.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.foregroundColor)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.mutedColor)
            }
        }
        .padding(24)
        .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.94 : 0.6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.panelBorderColor.opacity(0.35), lineWidth: 1)
        )
    }
}

struct QuickMetric: View {
    let title: String
    let value: String
    let trend: String
    let theme: TerminalTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundStyle(theme.mutedColor)
                .kerning(1)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundStyle(theme.foregroundColor)
            Text(trend)
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.94 : 0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.panelBorderColor.opacity(0.35), lineWidth: 1)
        )
    }
}
