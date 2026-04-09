import SwiftUI
import SwiftData

struct VLANGroupDetailView: View {
    let group: NetBoxVLANGroup
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false; @State private var ename = ""; @State private var emin = ""; @State private var emax = ""
    @State private var showingDeleteConfirmation = false
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Group Name", value: group.name)
                LabeledContent("Range (ID)", value: "\(group.minVID) - \(group.maxVID)")
            } header: {
                Text("Group Boundaries")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }
            
            Section {
                 if group.vlans.isEmpty { 
                     Text("Range is empty.")
                         .italic()
                         .foregroundStyle(selectedTheme.mutedColor) 
                 }
                 ForEach(group.vlans) { vlan in
                      HStack {
                           Text("\(vlan.vid)").font(.system(size: 10, weight: .bold)).foregroundStyle(.white).padding(4).background(selectedTheme.accentColor).cornerRadius(4)
                           Text(vlan.name)
                               .foregroundStyle(selectedTheme.foregroundColor)
                           Spacer()
                      }
                 }
            } header: {
                Text("VLAN Allocation Map")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }
            
        }
        .scrollContentBackground(.hidden)
        .alternatingRowBackgrounds(.disabled)
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                    endPoint: .bottom
            )
        )
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete Group", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                
                Button {
                    ename = group.name
                    emin = "\(group.minVID)"
                    emax = "\(group.maxVID)"
                    isEditing = true
                } label: {
                    Label("Edit Range", systemImage: "pencil")
                }
                .keyboardShortcut("e", modifiers: [.command])
            }
        }
        .alert("Delete Group?", isPresented: $showingDeleteConfirmation) {
            Button("Delete Group \(group.name)", role: .destructive) {
                modelContext.delete(group)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove the group. Note: The member VLANs will NOT be deleted, they will just become ungrouped.")
        }
        .sheet(isPresented: $isEditing) {
             VStack(spacing: 20) {
                  Text("Edit Group Constraints").font(.headline)
                      .foregroundStyle(selectedTheme.foregroundColor)
                  Form { 
                       TextField("Group Name", text: $ename)
                       TextField("Min VID", text: $emin); TextField("Max VID", text: $emax) 
                  }
                  HStack { 
                       Button("Cancel") { isEditing = false }; Spacer()
                       Button("Save") { 
                            group.name = ename; group.minVID = Int(emin) ?? 1; group.maxVID = Int(emax) ?? 4094; try? modelContext.save(); isEditing = false 
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
