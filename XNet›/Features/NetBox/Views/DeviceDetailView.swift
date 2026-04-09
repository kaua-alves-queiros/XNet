import SwiftUI
import SwiftData

struct DeviceDetailView: View {
    let device: NetBoxDevice
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false; @State private var editName = ""
    @State private var showingDeleteConfirmation = false
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Hostname", value: device.name)
                LabeledContent("Platform", value: device.deviceType)
                LabeledContent("Physical Location", value: device.site?.name ?? "Global Space")
            } header: {
                Text("Machine Assets")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }
            
            Section {
                 if device.assignedIPs.isEmpty { 
                     Text("No active IP documentation.")
                         .italic()
                         .foregroundStyle(selectedTheme.mutedColor) 
                 }
                 ForEach(device.assignedIPs) { ip in
                      HStack {
                           Text(ip.address).font(.system(.body, design: .monospaced, weight: .bold))
                               .foregroundStyle(selectedTheme.foregroundColor)
                           Spacer()
                           Text(ip.interfaceLabel ?? "LAN").font(.caption).foregroundStyle(selectedTheme.accentColor).padding(4).background(selectedTheme.accentColor.opacity(0.1)).cornerRadius(4)
                      }
                 }
            } header: {
                Text("IP Documented Interfaces")
                    .foregroundStyle(selectedTheme.mutedColor)
                    .font(.caption)
                    .bold()
            }

            if !device.notes.isEmpty {
                Section {
                    Text(device.notes)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(selectedTheme.foregroundColor.opacity(0.7))
                        .padding(.vertical, 4)
                } header: {
                    Text("Diagnostic & Config Notes")
                        .foregroundStyle(selectedTheme.mutedColor)
                        .font(.caption)
                        .bold()
                }
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
        .navigationTitle(device.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Decommission Device", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                
                Button {
                    editName = device.name
                    isEditing = true
                } label: {
                    Label("Edit Device", systemImage: "pencil")
                }
                .keyboardShortcut("e", modifiers: [.command])
            }
        }
        .sheet(isPresented: $isEditing) {
             VStack(spacing: 20) {
                  Text("Update Machine Asset").font(.headline)
                      .foregroundStyle(selectedTheme.foregroundColor)
                  Form { 
                      TextField("Hostname", text: $editName) 
                          .textFieldStyle(.roundedBorder)
                  }
                  HStack { 
                      Button("Cancel") { isEditing = false }
                      Spacer()
                      Button("Confirm") { 
                          device.name = editName; 
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
        .alert("Decommission Device?", isPresented: $showingDeleteConfirmation) {
            Button("Decommission", role: .destructive) {
                modelContext.delete(device)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete \(device.name)?")
        }
    }
}
