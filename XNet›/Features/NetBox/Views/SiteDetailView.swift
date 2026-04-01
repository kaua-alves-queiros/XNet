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
    }

    private var subtitle: String {
        "\(site.devices.count) devices • \(site.prefixes.count) prefixes"
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
        Form {
            Section("Physical Context") {
                LabeledContent("Site Name", value: site.name)
                LabeledContent("Inventory", value: "\(site.devices.count) Hardware Units")
                LabeledContent("Subnets", value: "\(site.prefixes.count) Subnet Prefixes")
            }

            Section("Devices in Site") {
                if site.devices.isEmpty {
                    Text("No physical machines.")
                        .italic()
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(site.devices) { dev in
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "cpu")
                                .foregroundStyle(.blue.gradient)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dev.name).bold()
                                Text(dev.deviceType)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }

            Section("Local Networks") {
                if site.prefixes.isEmpty {
                    Text("No prefixes in site.")
                        .italic()
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(site.prefixes) { p in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.cidr)
                                .font(.system(.body, design: .monospaced, weight: .bold))
                            if !p.prefixDescription.isEmpty {
                                Text(p.prefixDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if !site.siteDescription.isEmpty {
                Section("Technical Context") {
                    Text(site.siteDescription)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }

            Section("Actions") {
                Button {
                    beginEditing()
                } label: {
                    Label("Edit Site Details", systemImage: "pencil")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .formStyle(.grouped)
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
                Spacer()
                Button {
                    editSession = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                    TextEditor(text: $edesc)
                        .font(.body)
                        .frame(minHeight: 100)
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
                .disabled(ename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .onAppear {
            if ename.isEmpty { ename = site.name }
            if edesc.isEmpty { edesc = site.siteDescription }
        }
    }
}
#if DEBUG
#Preview("Site Detail (macOS)") {
    #if os(macOS)
    // Placeholder preview for macOS
    let sampleSite = NetBoxSite(name: "Sample Site", siteDescription: "A sample site for preview")
    SiteDetailView(site: sampleSite)
    #else
    EmptyView()
    #endif
}
#endif

