import SwiftUI

struct SettingsView: View {
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    @StateObject private var githubService = GitHubService()
    @Environment(\.openURL) private var openURL
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configurações")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedTheme.foregroundColor)
                    Text("Personalize sua experiência no XNet Professional")
                        .font(.title3)
                        .foregroundStyle(selectedTheme.mutedColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 40)
                
                // Theme Selection Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Label("Aparência e Temas", systemImage: "paintpalette.fill")
                            .font(.headline)
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Spacer()
                        Text(selectedTheme.displayName)
                            .font(.caption.bold())
                            .foregroundStyle(selectedTheme.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(selectedTheme.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(TerminalTheme.allCases) { theme in
                                ThemeGridItem(theme: theme, isSelected: selectedThemeID == theme.rawValue, currentTheme: selectedTheme) {
                                    selectedThemeID = theme.rawValue
                                    TerminalThemeStore.saveThemeID(theme.rawValue)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                
                // App Information
                VStack(alignment: .leading, spacing: 20) {
                    Label("Sobre o XNet", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "number", title: "Versão", value: "2.5.0 (Pro)", theme: selectedTheme)
                        Divider().background(selectedTheme.panelBorderColor.opacity(0.2)).padding(.horizontal, 16)
                        SettingsRow(icon: "person.2.fill", title: "Desenvolvedor", value: "Kaua Alves Queiros", theme: selectedTheme)
                        Divider().background(selectedTheme.panelBorderColor.opacity(0.2)).padding(.horizontal, 16)
                        SettingsRow(icon: "shield.fill", title: "Licença", value: "MIT License", theme: selectedTheme)
                    }
                    .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                }
                
                // Developers Section (GitHub API)
                VStack(alignment: .leading, spacing: 20) {
                    Label("Equipe de Desenvolvimento", systemImage: "person.3.fill")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    if githubService.isFetching && githubService.contributors.isEmpty {
                        ProgressView()
                            .padding(.horizontal, 32)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(githubService.contributors) { contributor in
                                    Button {
                                        if let url = URL(string: contributor.htmlUrl) {
                                            openURL(url)
                                        }
                                    } label: {
                                        VStack(spacing: 12) {
                                            AsyncImage(url: URL(string: contributor.avatarUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Circle().fill(Color.gray.opacity(0.2))
                                            }
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(selectedTheme.accentColor.opacity(0.4), lineWidth: 1))
                                            
                                            VStack(spacing: 2) {
                                                Text(contributor.login)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(selectedTheme.foregroundColor)
                                                Text("\(contributor.contributions) commits")
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(selectedTheme.mutedColor)
                                            }
                                        }
                                        .padding(.vertical, 16)
                                        .frame(width: 120)
                                        .background(selectedTheme.cardBackgroundColor.opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedTheme.panelBorderColor.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                }
                
                // Links Section
                VStack(alignment: .leading, spacing: 20) {
                    Label("Recursos Externos", systemImage: "link")
                        .font(.headline)
                        .foregroundStyle(selectedTheme.foregroundColor)
                        .padding(.horizontal, 32)
                    
                    Button {
                        if let url = URL(string: "https://github.com/kaua-alves-queiros/XNet") {
                            openURL(url)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(selectedTheme.isLight ? Color.black : Color.white)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "terminal.fill") // Custom GitHub-like icon
                                    .foregroundStyle(selectedTheme.isLight ? Color.white : Color.black)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Repositório GitHub")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(selectedTheme.foregroundColor)
                                Text("github.com/kaua-alves-queiros/XNet")
                                    .font(.caption)
                                    .foregroundStyle(selectedTheme.mutedColor)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(selectedTheme.mutedColor)
                        }
                        .padding(16)
                        .background(selectedTheme.cardBackgroundColor.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedTheme.panelBorderColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                }
                
                Spacer(minLength: 60)
            }
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                    endPoint: .bottom
            )
        )
        .onAppear {
            Task {
                await githubService.fetchContributors()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            }
        }
    }
}

struct ThemeGridItem: View {
    let theme: TerminalTheme
    let isSelected: Bool
    let currentTheme: TerminalTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Preview Box
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.backgroundColor)
                        .frame(height: 80)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.accentColor)
                            .frame(width: 40, height: 8)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.foregroundColor.opacity(0.6))
                            .frame(width: 60, height: 4)
                        HStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                Circle().fill(theme.mutedColor.opacity(0.4)).frame(width: 6, height: 6)
                            }
                        }
                    }
                    .padding(12)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? currentTheme.accentColor : currentTheme.foregroundColor)
                    Text(theme.appearanceLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(currentTheme.mutedColor)
                }
            }
            .padding(12)
            .frame(width: 140)
            .background(isSelected ? currentTheme.accentColor.opacity(0.12) : currentTheme.cardBackgroundColor.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? currentTheme.accentColor : currentTheme.panelBorderColor.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let theme: TerminalTheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(theme.foregroundColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.mutedColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
