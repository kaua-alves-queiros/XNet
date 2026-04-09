import SwiftUI
import SwiftData

struct VLANDetailView: View {
    let vlan: NetBoxVLAN
    let allDevices: [NetBoxDevice]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false; @State private var ename = ""; @State private var edesc = ""
    @State private var showingDeleteConfirmation = false
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("VID #", value: "\(vlan.vid)")
                LabeledContent("Name", value: vlan.name)
                LabeledContent("Group", value: vlan.vlanGroup?.name ?? "Ungrouped")
            } header: {
                Text("VLAN Strategy")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }
            
            Section {
                if vlan.prefixes.isEmpty { 
                    Text("Logical-only VLAN.")
                        .italic()
                        .foregroundStyle(selectedTheme.mutedColor) 
                }
                ForEach(vlan.prefixes) { prefix in
                    VStack(alignment: .leading) {
                        Text(prefix.cidr).font(.system(.body, design: .monospaced, weight: .bold))
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Text(prefix.prefixDescription).font(.caption)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                }
            } header: {
                Text("Layer 3 Context")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }
            
            if !vlan.vlanDescription.isEmpty {
                 Section { 
                     Text(vlan.vlanDescription)
                         .foregroundStyle(selectedTheme.foregroundColor.opacity(0.8)) 
                 } header: {
                     Text("Technical Notes")
                         .foregroundStyle(selectedTheme.mutedColor)
                         .font(.caption)
                         .bold()
                 }
            }
            
            Section {
                Button("Edit Details") { ename = vlan.name; edesc = vlan.vlanDescription; isEditing = true }
                    .foregroundStyle(selectedTheme.accentColor)
                Button("Delete VLAN", role: .destructive) { showingDeleteConfirmation = true }
                    .foregroundStyle(.red)
            } header: {
                Text("Actions")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
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
        .navigationTitle("VLAN \(vlan.vid)")
        .confirmationDialog("Delete VLAN?", isPresented: $showingDeleteConfirmation) {
            Button("Delete VLAN \(vlan.vid)", role: .destructive) {
                modelContext.delete(vlan)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove the VLAN from the inventory. All associated prefixes will be unlinked.")
        }
        .sheet(isPresented: $isEditing) {
             VStack(spacing: 20) {
                  Text("Edit Virtual LAN").font(.headline)
                      .foregroundStyle(selectedTheme.foregroundColor)
                  Form { 
                      TextField("Name", text: $ename) 
                      TextField("Description", text: $edesc) 
                  }
                  HStack { 
                      Button("Cancel") { isEditing = false }
                      Spacer()
                      Button("Update") { 
                          vlan.name = ename; 
                          vlan.vlanDescription = edesc; 
                          try? modelContext.save(); 
                          isEditing = false 
                      }
                      .buttonStyle(.borderedProminent)
                      .tint(selectedTheme.accentColor)
                  }
             }
             .padding()
             .frame(width: 320)
             .background(selectedTheme.backgroundColor)
             .cornerRadius(12)
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
    }
}
