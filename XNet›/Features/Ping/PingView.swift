import SwiftUI

struct PingView: View {
    @State private var pingService = PingService()
    @State private var targetHost: String = "google.com"
    @State private var pingResults: [PingResult] = []
    @State private var isRunning = false
    @State private var currentTask: Task<Void, Never>? = nil
    @State private var selectedThemeID = TerminalThemeStore.readThemeID()
    
    private var selectedTheme: TerminalTheme {
        TerminalTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // High-End Header
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Latency Monitor")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Text(isRunning ? "Pinging \(targetHost)..." : "Enter a host to start diagnostic")
                            .font(.subheadline)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if isRunning {
                            ProgressView()
                                .controlSize(.small)
                        } else if !pingResults.isEmpty {
                            let avg = pingResults.map(\.time).reduce(0, +) / Double(pingResults.count)
                            HStack(spacing: 4) {
                                Text("AVG")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.2f ms", avg))
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundStyle(avg < 50 ? .green : (avg < 150 ? .orange : .red))
                            }
                            .padding(.trailing, 8)
                        }
                        
                        Button(action: {
                            isRunning ? stopPing() : startPing()
                        }) {
                            HStack {
                                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                Text(isRunning ? "Stop" : "Ping Now")
                            }
                            .frame(width: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(isRunning ? .red : selectedTheme.accentColor)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                
                // Search & Input Bar
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14, weight: .bold))
                        
                        TextField("Host or IP (e.g. google.com)", text: $targetHost)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(selectedTheme.cardBackgroundColor.opacity(selectedTheme.isLight ? 0.94 : 0.6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedTheme.panelBorderColor.opacity(0.35), lineWidth: 1)
                    )
                    .disabled(isRunning)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: { pingResults.removeAll() }) {
                        Image(systemName: "broom.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("Clear Results")
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 24)

            // MARK: - Technical Results Table
            Table(pingResults) {
                TableColumn("Seq") { res in
                    Text("\(res.sequence)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .width(40)
                
                TableColumn("IP / Interface") { res in
                    Text(res.ip)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                        .foregroundStyle(res.bytes == 0 ? .red : selectedTheme.foregroundColor)
                }
                .width(220)
                
                TableColumn("Payload") { res in
                    Text(res.bytes > 0 ? "\(res.bytes) bytes" : "---")
                        .foregroundStyle(.tertiary)
                }
                .width(100)
                
                TableColumn("TTL") { res in
                    Text(res.ttl > 0 ? "\(res.ttl)" : "---")
                        .foregroundStyle(.secondary)
                }
                .width(60)
                
                TableColumn("Latency") { res in
                    HStack(spacing: 8) {
                        if res.bytes > 0 && res.time > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(res.time < 50 ? .green : (res.time < 150 ? .orange : .red))
                                .frame(width: 4, height: 16)
                            
                            Text(String(format: "%.2f ms", res.time))
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .foregroundColor(res.time < 50 ? .green : (res.time < 150 ? .orange : .red))
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.red.opacity(0.3))
                                .frame(width: 4, height: 16)
                            Text("TIMED OUT")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                }
            }
            .tableStyle(.inset)
            .scrollContentBackground(.hidden)
            .alternatingRowBackgrounds(.disabled)
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Ping Diagnostic")
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
        .onDisappear {
            stopPing()
        }
    }
    
    private func startPing() {
        pingResults.removeAll()
        isRunning = true
        
        currentTask = Task {
            let stream = pingService.ping(host: targetHost)
            for await result in stream {
                if Task.isCancelled { break }
                pingResults.append(result)
            }
            isRunning = false
        }
    }
    
    private func stopPing() {
        currentTask?.cancel()
        currentTask = nil
        isRunning = false
    }
}
