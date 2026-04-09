import SwiftUI

struct TerminalSnippetLibrarySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let snippets: [XNetTerminalSnippet]
    @Binding var searchText: String
    let canSend: Bool
    let onAdd: () -> Void
    let onEdit: (XNetTerminalSnippet) -> Void
    let onDelete: (XNetTerminalSnippet) -> Void
    let onSend: (XNetTerminalSnippet) -> Void
    let onSave: (TerminalSnippetPayload) -> Void
    let editingSnippet: XNetTerminalSnippet?
    
    @State private var showingForm = false
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Biblioteca de Snippets")
                        .font(.title3.bold())
                        .foregroundStyle(selectedTheme.foregroundColor)
                    Text("Comandos persistentes para reuso rápido")
                        .font(.caption)
                        .foregroundStyle(selectedTheme.mutedColor)
                }
                Spacer()
                Button {
                    onAdd()
                    showingForm = true
                } label: {
                    Label("Novo Snippet", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .keyboardShortcut(.defaultAction)
                
                Button("Fechar") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(selectedTheme.mutedColor)
                TextField("Buscar snippet", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(selectedTheme.foregroundColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(selectedTheme.cardBackgroundColor.opacity(selectedTheme.isLight ? 0.95 : 0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTheme.panelBorderColor.opacity(0.35), lineWidth: 1))
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(snippets) { snippet in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(snippet.title)
                                        .font(.headline)
                                        .foregroundStyle(selectedTheme.foregroundColor)
                                    if !snippet.notes.isEmpty {
                                        Text(snippet.notes)
                                            .font(.caption)
                                            .foregroundStyle(selectedTheme.mutedColor)
                                    }
                                }
                                
                                Spacer()
                                
                                if snippet.sendReturn {
                                    Text("ENTER")
                                        .font(.system(size: 10, weight: .semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedTheme.accentColor.opacity(0.12))
                                        .foregroundStyle(selectedTheme.accentColor)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(snippet.command)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .background(selectedTheme.backgroundColor.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1))
                            
                            HStack {
                                Button {
                                    onEdit(snippet)
                                    showingForm = true
                                } label: {
                                    Label("Editar", systemImage: "square.and.pencil")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                
                                Button(role: .destructive) {
                                    onDelete(snippet)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                
                                Spacer()
                                
                                Button {
                                    onSend(snippet)
                                    dismiss()
                                } label: {
                                    Label("Executar", systemImage: "play.fill")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(selectedTheme.accentColor)
                                .controlSize(.small)
                                .disabled(!canSend)
                            }
                        }
                        .padding(14)
                        .background(selectedTheme.cardBackgroundColor.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 620, height: 620)
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $showingForm) {
            TerminalSnippetFormSheet(snippetToEdit: editingSnippet, onSave: onSave)
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
    }
}

struct TerminalLogHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let logs: [XNetTerminalLog]
    @Binding var searchText: String
    let onDelete: (XNetTerminalLog) -> Void
    let onClear: () -> Void
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    
    init(logs: [XNetTerminalLog], searchText: Binding<String>, onDelete: @escaping (XNetTerminalLog) -> Void, onClear: @escaping () -> Void) {
        self.logs = logs
        self._searchText = searchText
        self.onDelete = onDelete
        self.onClear = onClear
    }

    private var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Histórico de Sessões")
                        .font(.title3.bold())
                        .foregroundStyle(selectedTheme.foregroundColor)
                    Text("Logs de conexões anteriores")
                        .font(.caption)
                        .foregroundStyle(selectedTheme.mutedColor)
                }
                Spacer()
                if !logs.isEmpty {
                    Button("Limpar Tudo", role: .destructive) {
                        onClear()
                    }
                    .buttonStyle(.bordered)
                }
                Button("Fechar") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(selectedTheme.accentColor)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(selectedTheme.mutedColor)
                TextField("Buscar por host, usuário ou conteúdo", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(selectedTheme.foregroundColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(selectedTheme.cardBackgroundColor.opacity(selectedTheme.isLight ? 0.95 : 0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1))
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(logs) { entry in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.headline)
                                        .foregroundStyle(selectedTheme.foregroundColor)
                                    Text(entry.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(selectedTheme.mutedColor)
                                    Text("Início: \(formatter.string(from: entry.startedAt)) • Fim: \(formatter.string(from: entry.endedAt))")
                                        .font(.caption2)
                                        .foregroundStyle(selectedTheme.mutedColor.opacity(0.8))
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    onDelete(entry)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(entry.content)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .background(selectedTheme.backgroundColor.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1))
                        }
                        .padding(14)
                        .background(selectedTheme.cardBackgroundColor.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1))
                    }
                    
                    if logs.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 40))
                                .foregroundStyle(selectedTheme.mutedColor.opacity(0.5))
                            Text("Nenhum log disponível")
                                .font(.headline)
                                .foregroundStyle(selectedTheme.foregroundColor)
                            Text("As sessões encerradas aparecem aqui automaticamente.")
                                .font(.subheadline)
                                .foregroundStyle(selectedTheme.mutedColor)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 860, height: 620)
        .background(
            LinearGradient(
                colors: [selectedTheme.sidebarTopColor, selectedTheme.sidebarBottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
    }
}

struct TerminalSnippetFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let snippetToEdit: XNetTerminalSnippet?
    let onSave: (TerminalSnippetPayload) -> Void
    
    @State private var title = ""
    @State private var command = ""
    @State private var notes = ""
    @State private var sendReturn = true
    
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(snippetToEdit == nil ? "Novo Snippet" : "Editar Snippet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(selectedTheme.foregroundColor)
            
            Form {
                Section("IDENTIFICAÇÃO") {
                    TextField("Título", text: $title)
                    TextField("Observações", text: $notes)
                }
                
                Section("COMANDO") {
                    TextEditor(text: $command)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 120)
                    Toggle("Enviar Enter ao final", isOn: $sendReturn)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            HStack(spacing: 16) {
                Button("Cancelar") { dismiss() }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Salvar") {
                    onSave(TerminalSnippetPayload(
                        title: title.isEmpty ? "Snippet" : title,
                        command: command,
                        notes: notes,
                        sendReturn: sendReturn
                    ))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.accentColor)
                .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
        .frame(width: 440, height: 520)
        .background(selectedTheme.backgroundColor)
        .onAppear {
            if let snippet = snippetToEdit {
                title = snippet.title
                command = snippet.command
                notes = snippet.notes
                sendReturn = snippet.sendReturn
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
    }
}
