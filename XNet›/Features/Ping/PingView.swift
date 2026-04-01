//
//  PingView.swift
//  XNet›
//

import SwiftUI

struct PingView: View {
    @State private var pingService = PingService()
    @State private var targetHost: String = "google.com"
    @State private var pingResults: [PingResult] = []
    @State private var isRunning = false
    @State private var currentTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Text("Ping")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding([.top, .horizontal])
            
            HStack {
                TextField("Host or IP", text: $targetHost)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isRunning)
                
                Button(action: {
                    if isRunning {
                        stopPing()
                    } else {
                        startPing()
                    }
                }) {
                    Text(isRunning ? "Stop" : "Start")
                        .frame(width: 80)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            
            Table(pingResults) {
                TableColumn("Seq") { res in
                    Text("\(res.sequence)")
                        .foregroundColor(.secondary)
                }
                .width(50)
                
                TableColumn("IP Address") { res in
                    Text(res.ip)
                        .font(.system(.body, design: .monospaced))
                }
                
                TableColumn("Bytes") { res in
                    Text("\(res.bytes)")
                        .foregroundColor(.blue)
                }
                .width(60)
                
                TableColumn("TTL") { res in
                    Text("\(res.ttl)")
                }
                .width(50)
                
                TableColumn("Time") { res in
                    Text(String(format: "%.2f ms", res.time))
                        .bold()
                        .foregroundColor(res.time < 50 ? .green : (res.time < 150 ? .yellow : .red))
                }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            
            HStack {
                Text(isRunning ? "Pinging \(targetHost)..." : "Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if !pingResults.isEmpty {
                    let avg = pingResults.map(\.time).reduce(0, +) / Double(pingResults.count)
                    Text(String(format: "Avg: %.2f ms", avg))
                        .font(.caption.bold())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Ping")
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
