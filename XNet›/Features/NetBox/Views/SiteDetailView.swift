import SwiftUI
import SwiftData
import Combine

@MainActor
struct SiteDetailView: View {
    let site: NetBoxSite
    @Environment(\.modelContext) private var modelContext

    // Editing state
    private struct EditSession: Identifiable { let id = UUID() }
    @State private var editSession: EditSession? = nil
    @State private var ename = ""
    @State private var edesc = ""
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        content
            .navigationTitle(site.name)
            .navigationSubtitle(subtitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        beginEditing()
                    } label: {
                        Label("Edit Site Details", systemImage: "pencil")
                    }
                    .keyboardShortcut("e", modifiers: [.command])
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .sheet(item: $editSession) { _ in
                editSheet
                    #if os(macOS)
                    .frame(minWidth: 440, idealWidth: 560, maxWidth: 720,
                           minHeight: 280, idealHeight: 340, maxHeight: 560)
                    .padding()
                    #else
                    .presentationDetents([.medium, .large])
                    #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
                if let themeID = output.object as? String {
                    selectedThemeID = themeID
                } else {
                    selectedThemeID = TerminalThemeStore.readThemeID()
                }
            }
    }

    private var subtitle: String {
        "\(site.devices.count) devices • \(site.prefixes.count) prefixes"
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
        Form {
            Section {
                LabeledContent("Site Name", value: site.name)
                LabeledContent("Inventory", value: "\(site.devices.count) Hardware Units")
                LabeledContent("Subnets", value: "\(site.prefixes.count) Subnet Prefixes")
            } header: {
                Text("Physical Context")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }

            Section {
                if site.devices.isEmpty {
                    Text("No physical machines.")
                        .italic()
                        .foregroundStyle(selectedTheme.mutedColor)
                } else {
                    ForEach(site.devices) { dev in
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "cpu")
                                .foregroundStyle(selectedTheme.accentColor.gradient)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dev.name).bold()
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                Text(dev.deviceType)
                                    .font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(selectedTheme.mutedColor.opacity(0.3))
                        }
                        .contentShape(Rectangle())
                    }
                }
            } header: {
                Text("Devices in Site")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }

            Section {
                if site.prefixes.isEmpty {
                    Text("No prefixes in site.")
                        .italic()
                        .foregroundStyle(selectedTheme.mutedColor)
                } else {
                    ForEach(site.prefixes) { p in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.cidr)
                                .font(.system(.body, design: .monospaced, weight: .bold))
                                .foregroundStyle(selectedTheme.foregroundColor)
                            if !p.prefixDescription.isEmpty {
                                Text(p.prefixDescription)
                                    .font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor)
                            }
                        }
                    }
                }
            } header: {
                Text("Local Networks")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }

            if !site.siteDescription.isEmpty {
                Section {
                    Text(site.siteDescription)
                        .foregroundStyle(selectedTheme.foregroundColor.opacity(0.8))
                        .textSelection(.enabled)
                } header: {
                    Text("Technical Context")
                        .foregroundStyle(selectedTheme.mutedColor)
                        .font(.caption)
                        .bold()
                }
            }

            Section {
                Button {
                    beginEditing()
                } label: {
                    Label("Edit Site Details", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .alternatingRowBackgrounds(.disabled)
        .foregroundStyle(selectedTheme.foregroundColor)
        #else
        List {
            Section("Physical Context") {
                LabeledContent("Site Name", value: site.name)
                LabeledContent("Inventory", value: "\(site.devices.count) Hardware Units")
                LabeledContent("Subnets", value: "\(site.prefixes.count) Subnet Prefixes")
            }

            Section("Devices in Site") {
                if site.devices.isEmpty { Text("No physical machines.").italic().foregroundStyle(.secondary) }
                ForEach(site.devices) { dev in
                    HStack {
                        Image(systemName: "cpu").foregroundStyle(.blue.gradient)
                        VStack(alignment: .leading) { Text(dev.name).bold(); Text(dev.deviceType).font(.caption).foregroundStyle(.secondary) }
                        Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Section("Local Networks") {
                if site.prefixes.isEmpty { Text("No prefixes in site.").italic().foregroundStyle(.secondary) }
                ForEach(site.prefixes) { p in
                    VStack(alignment: .leading) {
                        Text(p.cidr).font(.system(.body, design: .monospaced, weight: .bold))
                        Text(p.prefixDescription).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            if !site.siteDescription.isEmpty {
                Section("Technical Context") { Text(site.siteDescription).foregroundStyle(.secondary) }
            }

            Section("Actions") {
                Button("Edit Site Details") { beginEditing() }.foregroundStyle(.blue)
            }
        }
        #endif
    }

    private func beginEditing() {
        ename = site.name
        edesc = site.siteDescription
        editSession = EditSession()
    }

    private var editSheet: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Edit Physical Site")
                    .font(.headline)
                    .foregroundStyle(selectedTheme.foregroundColor)
                Spacer()
                Button {
                    editSession = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(selectedTheme.mutedColor)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }

            #if os(macOS)
            Form {
                TextField("Name", text: $ename)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(selectedTheme.mutedColor)
                    TextEditor(text: $edesc)
                        .font(.body)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(4)
                }
            }
            .formStyle(.grouped)
            #else
            Form {
                TextField("Name", text: $ename)
                TextField("Description", text: $edesc)
            }
            #endif

            HStack {
                Button("Cancel") {
                    editSession = nil
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Update") {
                    let trimmed = ename.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    site.name = trimmed
                    site.siteDescription = edesc
                    try? modelContext.save()
                    editSession = nil
                }
                .keyboardShortcut("s", modifiers: [.command])
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .disabled(ename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(selectedTheme.backgroundColor)
        .onAppear {
            if ename.isEmpty { ename = site.name }
            if edesc.isEmpty { edesc = site.siteDescription }
        }
    }
}
