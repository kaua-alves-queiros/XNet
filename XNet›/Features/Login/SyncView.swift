import SwiftUI

struct SyncView: View {
    @StateObject private var syncService = XNetSyncService.shared
    @Environment(\.dismiss) private var dismiss
    
    var theme: TerminalTheme = .defaultTheme
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(theme.accentColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(theme.accentColor)
                        .rotationEffect(.degrees(syncService.isSyncing ? 360 : 0))
                        .animation(syncService.isSyncing ? .linear(duration: 2).repeatForever(autoreverses: false) : .default, value: syncService.isSyncing)
                }
                
                Text(syncService.isSyncing ? "Sincronizando..." : "Escolha como Sincronizar")
                    .font(.title2.bold())
                    .foregroundStyle(theme.foregroundColor)
                
                Text(syncService.isSyncing ? syncService.progressMessage : "Detectamos que você se conectou a um XNet Self-Hosted. Como deseja gerenciar seus dispositivos?")
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !syncService.isSyncing {
                VStack(spacing: 16) {
                    SyncOptionCard(
                        title: "Baixar do Servidor (PULL)",
                        description: "Apaga seus dados locais e usa apenas o que está no servidor.",
                        icon: "arrow.down.circle.fill",
                        color: .blue,
                        theme: theme
                    ) {
                        performSync(.pull)
                    }
                    
                    SyncOptionCard(
                        title: "Forçar para o Servidor (PUSH)",
                        description: "Substitui os dados do servidor pelos seus dispositivos locais.",
                        icon: "arrow.up.circle.fill",
                        color: .orange,
                        theme: theme
                    ) {
                        performSync(.push)
                    }
                    
                    SyncOptionCard(
                        title: "Combinar Dados (MERGE)",
                        description: "Une os dois bancos de dados sem apagar duplicatas óbvias.",
                        icon: "plus.circle.fill",
                        color: .green,
                        theme: theme
                    ) {
                        performSync(.merge)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                    
                    Button("Cancelar") {
                        // Poderíamos adicionar lógica de cancelamento
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.mutedColor)
                }
                .frame(height: 250)
            }
        }
        .padding(40)
        .frame(width: 480)
        .background(theme.backgroundColor)
    }
    
    private func performSync(_ strategy: SyncStrategy) {
        Task {
            if await syncService.performSync(strategy: strategy) {
                // Notificar reload
                NotificationCenter.default.post(name: NSNotification.Name("TerminalDataReload"), object: nil)
                dismiss()
            }
        }
    }
}

struct SyncOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let theme: TerminalTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.foregroundColor)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.mutedColor)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(theme.mutedColor.opacity(0.5))
            }
            .padding(16)
            .background(isHovered ? theme.accentColor.opacity(0.1) : theme.cardBackgroundColor.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHovered ? theme.accentColor.opacity(0.3) : theme.panelBorderColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
