import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var authService = XNetAuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSync = false
    var theme: TerminalTheme = .defaultTheme
    
    var body: some View {
        Group {
            if showingSync {
                SyncView(theme: theme)
            } else {
                loginContent
            }
        }
    }
    
    private var loginContent: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.accentColor.gradient)
                    .padding(.bottom, 10)
                
                Text("Acesso Restrito")
                    .font(.title.bold())
                    .foregroundStyle(theme.foregroundColor)
                
                Text("Faça login no seu nó self-hosted para sincronizar dados e telemetria.")
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Form
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("E-MAIL")
                        .font(.caption.bold())
                        .foregroundStyle(theme.mutedColor)
                    TextField("seu@email.com", text: $email)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(theme.cardBackgroundColor.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.panelBorderColor.opacity(0.2), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("SENHA")
                        .font(.caption.bold())
                        .foregroundStyle(theme.mutedColor)
                    SecureField("••••••••", text: $password)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(theme.cardBackgroundColor.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.panelBorderColor.opacity(0.2), lineWidth: 1))
                }
            }
            
            if let error = authService.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
            
            Button {
                Task {
                    if await authService.login(email: email, password: password) {
                        withAnimation { showingSync = true }
                    }
                }
            } label: {
                HStack {
                    if authService.isAuthenticating {
                        ProgressView().controlSize(.small).padding(.trailing, 4)
                    }
                    Text(authService.isAuthenticating ? "Autenticando..." : "Entrar no XNet Self-Hosted")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(authService.isAuthenticating || email.isEmpty || password.isEmpty)
            
            Button("Configurações de Link") {
                dismiss()
            }
            .font(.caption)
            .foregroundStyle(theme.mutedColor)
        }
        .padding(40)
        .frame(width: 400)
        .background(theme.backgroundColor)
    }
}
