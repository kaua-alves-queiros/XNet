//
//  PortScanView.swift
//  XNet›
//

import SwiftUI

enum PortScanPreset: String, CaseIterable, Identifiable {
    case common = "Common Ports"
    case all = "All Ports (1-65535)"
    case custom = "Custom Range"
    
    var id: String { self.rawValue }
    
    var portsString: String {
        switch self {
        case .common:
            return "21 22 23 25 53 80 110 135 139 143 443 445 1433 1521 3306 3389 5432 5900 8080"
        case .all:
            return "1-65535"
        case .custom:
            return ""
        }
    }
}

struct PortScanView: View {
    @State private var targetHost: String = "google.com"
    @State private var selectedPreset: PortScanPreset = .common
    @State private var customPorts: String = "80-100"
    
    @State private var scannedPorts: [ScannedPort] = []
    @State private var isRunning = false
    @State private var statusText: String = "Select a preset or enter a custom port range."
    @State private var currentTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "bolt.horizontal")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Text("Port Scan")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding([.top, .horizontal])
            
            HStack {
                TextField("Address (e.g. google.com)", text: $targetHost)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isRunning)
                
                Picker("", selection: $selectedPreset) {
                    ForEach(PortScanPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .frame(width: 180)
                .disabled(isRunning)
                
                if selectedPreset == .custom {
                    TextField("Ex: 80-100 ou 80 443", text: $customPorts)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .disabled(isRunning)
                }
                
                Button(action: {
                    if isRunning {
                        stopScan()
                    } else {
                        startPortScan()
                    }
                }) {
                    Text(isRunning ? "Stop" : "Scan")
                        .frame(width: 80)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            
            Table(scannedPorts) {
                TableColumn("Port") { sp in
                    Text("\(sp.port)")
                        .bold()
                }
                .width(60)
                
                TableColumn("State") { sp in
                    Text(sp.state)
                        .foregroundColor(sp.state == "Open" ? .green : .secondary)
                }
                .width(150)
                
                TableColumn("Service / Protocol") { sp in
                    Text(sp.protocolName)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .navigationTitle("Port Scan")
        .onDisappear {
            stopScan()
        }
    }
    
    private func startPortScan() {
        scannedPorts.removeAll()
        isRunning = true
        
        let targetPorts: [Int]
        if selectedPreset == .custom {
            targetPorts = parsePorts(customPorts)
        } else {
            targetPorts = parsePorts(selectedPreset.portsString)
        }
        
        statusText = "Scanning native ports on \(targetHost)..."
        
        currentTask = Task {
            let stream = PortScannerService.scan(host: targetHost, ports: targetPorts)
            for await port in stream {
                if Task.isCancelled { break }
                scannedPorts.append(port)
                scannedPorts.sort(by: { $0.port < $1.port })
            }
            isRunning = false
            statusText = "Scan Complete. Found \(scannedPorts.count) open ports."
        }
    }
    
    private func stopScan() {
        currentTask?.cancel()
        currentTask = nil
        isRunning = false
        statusText = "Scan stopped."
    }
    
    private func parsePorts(_ input: String) -> [Int] {
        var result: [Int] = []
        let parts = input.replacingOccurrences(of: ",", with: " ").components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        for part in parts {
            if part.contains("-") {
                let range = part.components(separatedBy: "-")
                if range.count == 2, let start = Int(range[0]), let end = Int(range[1]) {
                    for p in start...end { result.append(p) }
                }
            } else if let p = Int(part) {
                result.append(p)
            }
        }
        return Array(Set(result)).sorted()
    }
}
