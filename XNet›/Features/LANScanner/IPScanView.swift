//
//  IPScanView.swift
//  XNet›
//

import SwiftUI

struct IPScanView: View {
    @State private var lanScanner = LANScannerService()
    @State private var subnet: String = "192.168.1.0/24"
    @State private var scannedDevices: [ScannedDevice] = []
    @State private var isScanning = false
    @State private var currentTask: Task<Void, Never>? = nil
    @State private var statusText: String = "Enter IP range (e.g. 192.168.1.0/24 or 10.0.0.1-10.0.0.50)"
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "wifi.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Text("IP Scanner")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding([.top, .horizontal])
            
            HStack {
                HStack(spacing: 5) {
                    TextField("192.168.1.0/24", text: $subnet)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 200, maxWidth: .infinity)
                }
                .disabled(isScanning)
                
                Button(action: {
                    if isScanning {
                        stopScan()
                    } else {
                        startScan()
                    }
                }) {
                    Text(isScanning ? "Stop" : "Scan Network")
                        .frame(width: 120)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            
            Table(scannedDevices) {
                TableColumn("IP Address") { device in
                    Text(device.ip)
                        .bold()
                }
                .width(150)
                
                TableColumn("MAC Address") { device in
                    Text(device.mac)
                        .font(.system(.body, design: .monospaced))
                }
                
                TableColumn("Hostname") { device in
                    Text(device.hostname)
                        .foregroundColor(.secondary)
                }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            
            HStack {
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if isScanning {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("IP Scan")
        .onDisappear {
            stopScan()
        }
    }
    
    private func startScan() {
        scannedDevices.removeAll()
        isScanning = true
        statusText = "Scanning native subnet \(subnet)..."
        
        currentTask = Task {
            let stream = lanScanner.scan(subnet: subnet)
            var buffer: [ScannedDevice] = []
            var lastUpdate = Date()
            
            for await device in stream {
                if Task.isCancelled { break }
                buffer.append(device)
                
                // Batch updates every 10 devices or every 250ms to keep UI fluid
                if buffer.count >= 10 || Date().timeIntervalSince(lastUpdate) > 0.25 {
                    scannedDevices.append(contentsOf: buffer)
                    
                    // Ordenação inteligente por octetos numéricos do IP
                    scannedDevices.sort { dev1, dev2 in
                        let parts1 = dev1.ip.split(separator: ".").compactMap { Int($0) }
                        let parts2 = dev2.ip.split(separator: ".").compactMap { Int($0) }
                        for i in 0..<min(parts1.count, parts2.count) {
                            if parts1[i] != parts2[i] { return parts1[i] < parts2[i] }
                        }
                        return parts1.count < parts2.count
                    }
                    
                    buffer.removeAll()
                    lastUpdate = Date()
                }
            }
            
            if !buffer.isEmpty {
                scannedDevices.append(contentsOf: buffer)
                // Ordenação final
                scannedDevices.sort { dev1, dev2 in
                    let parts1 = dev1.ip.split(separator: ".").compactMap { Int($0) }
                    let parts2 = dev2.ip.split(separator: ".").compactMap { Int($0) }
                    for i in 0..<min(parts1.count, parts2.count) {
                        if parts1[i] != parts2[i] { return parts1[i] < parts2[i] }
                    }
                    return parts1.count < parts2.count
                }
            }
            
            isScanning = false
            statusText = "Scan Complete. Found \(scannedDevices.count) live devices."
        }
    }
    
    private func stopScan() {
        currentTask?.cancel()
        currentTask = nil
        isScanning = false
        statusText = "Scan stopped."
    }
}
