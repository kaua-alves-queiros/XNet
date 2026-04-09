import SwiftUI

struct TerminalDeviceFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let deviceToEdit: XNetTerminalDevice?
    let availableGroups: [String]
    let onSave: (TerminalDevicePayload) -> Void
    
    @State private var name = ""
    @State private var connectionType: XNetTerminalConnectionType = .ssh
    @State private var groupName = "Geral"
    @State private var host = ""
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var notes = ""
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(deviceToEdit == nil ? "Novo Dispositivo" : "Editar Dispositivo")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(selectedTheme.foregroundColor)
            
            Form {
                Section {
                    TextField("Nome", text: $name)
                    Picker("Grupo/Pasta", selection: $groupName) {
                        ForEach(availableGroups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                } header: {
                    Text("IDENTIFICAÇÃO").font(.caption2).bold()
                }
                
                Section {
                    Picker("Tipo de Conexão", selection: $connectionType) {
                        ForEach(XNetTerminalConnectionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField(connectionType == .serial ? "Porta serial" : "Host/IP", text: $host)
                    TextField(connectionType == .serial ? "Baud rate" : "Porta", text: $port)
                } header: {
                    Text("CONECTIVIDADE").font(.caption2).bold()
                }
                
                if connectionType == .ssh || connectionType != .serial {
                    Section {
                        if connectionType == .ssh {
                            TextField("Usuário", text: $username)
                        }
                        SecureField("Senha", text: $password)
                    } header: {
                        Text("AUTENTICAÇÃO").font(.caption2).bold()
                    }
                }

                Section {
                    TextField("Notas/Observações", text: $notes)
                } header: {
                    Text("DIVERSOS").font(.caption2).bold()
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            HStack(spacing: 16) {
                Button("Cancelar") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
                
                Button("Salvar") {
                    onSave(
                        TerminalDevicePayload(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Dispositivo" : name,
                            groupName: groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Geral" : groupName,
                            connectionType: connectionType.rawValue,
                            host: host,
                            port: port,
                            username: username,
                            password: password,
                            notes: notes
                        )
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && connectionType != .serial)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 24)
        .frame(width: 480, height: 620)
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            if let firstGroup = availableGroups.first {
                if groupName == "Geral" { groupName = firstGroup }
            }
            guard let device = deviceToEdit else { return }
            name = device.name
            connectionType = XNetTerminalConnectionType(rawValue: device.connectionType) ?? .ssh
            groupName = device.groupName
            host = device.host
            port = device.port
            username = device.username
            password = TerminalPasswordStore.readPassword(credentialID: device.credentialID) ?? ""
            notes = device.notes
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
        .onChange(of: connectionType) { _, value in
            if deviceToEdit != nil { return }
            switch value {
            case .ssh:
                port = "22"
            case .telnet:
                port = "23"
            case .serial:
                port = "115200"
            }
        }
    }
}

struct TerminalDeviceGroupFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    let onSave: (String) -> Void
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Nova Pasta de Rede")
                .font(.headline)
                .foregroundStyle(selectedTheme.foregroundColor)
            
            Form {
                TextField("Nome da pasta", text: $name)
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            HStack {
                Button("Cancelar") { dismiss() }
                Spacer()
                Button("Criar") {
                    onSave(name)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
        .background(selectedTheme.backgroundColor)
        .cornerRadius(16)
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
    }
}
