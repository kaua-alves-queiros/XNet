import SwiftUI

struct TracerouteView: View {
    @State private var tracerouteService = TracerouteService()
    @State private var targetHost: String = "google.com"
    @State private var hops: [TracerouteHop] = []
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
                        Text("Route Trace")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedTheme.foregroundColor)
                        Text(isRunning ? "Tracing route to \(targetHost)..." : "Map the path to a remote host")
                            .font(.subheadline)
                            .foregroundStyle(selectedTheme.mutedColor)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if isRunning {
                            ProgressView()
                                .controlSize(.small)
                        }
                        
                        Button(action: {
                            isRunning ? stopTrace() : startTrace()
                        }) {
                            HStack {
                                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                Text(isRunning ? "Stop" : "Trace")
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
                        Image(systemName: "map.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14, weight: .bold))
                        
                        TextField("Host or IP (e.g. 1.1.1.1)", text: $targetHost)
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
                    
                    Button(action: { hops.removeAll() }) {
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

            // Modern Results Table
            Table(hops) {
                TableColumn("Hop") { hop in
                    Text("\(hop.id)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .width(40)
                
                TableColumn("Node Address") { hop in
                    Text(hop.ip)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                        .foregroundStyle(selectedTheme.foregroundColor)
                }
                .width(180)
                
                TableColumn("T1") { hop in 
                    Text(hop.time1)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(hop.time1.contains("*") ? .red : selectedTheme.foregroundColor)
                }
                
                TableColumn("T2") { hop in 
                    Text(hop.time2)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(hop.time2.contains("*") ? .red : selectedTheme.foregroundColor)
                }
                
                TableColumn("T3") { hop in 
                    Text(hop.time3)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(hop.time3.contains("*") ? .red : selectedTheme.foregroundColor)
                }
            }
            .tableStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .background(
            LinearGradient(
                colors: [selectedTheme.chromeTopColor, selectedTheme.chromeBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Traceroute Diagnostic")
        .onReceive(NotificationCenter.default.publisher(for: TerminalThemeStore.didChangeNotification)) { output in
            if let themeID = output.object as? String {
                selectedThemeID = themeID
            } else {
                selectedThemeID = TerminalThemeStore.readThemeID()
            }
        }
        .onDisappear {
            stopTrace()
        }
    }
    
    private func startTrace() {
        hops.removeAll()
        isRunning = true
        
        currentTask = Task {
            let stream = tracerouteService.trace(host: targetHost)
            for await hop in stream {
                if Task.isCancelled { break }
                hops.append(hop)
            }
            isRunning = false
        }
    }
    
    private func stopTrace() {
        currentTask?.cancel()
        currentTask = nil
        isRunning = false
    }
}
