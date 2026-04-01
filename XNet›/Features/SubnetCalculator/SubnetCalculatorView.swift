//
//  SubnetCalculatorView.swift
//  XNet›
//

import SwiftUI

struct SubnetCalculatorView: View {
    @State private var ipAddress: String = "192.168.1.1"
    @State private var cidr: Double = 24
    @State private var service = SubnetCalculatorService()
    
    private var subnetInfo: SubnetInfo? {
        service.calculate(address: ipAddress, cidr: Int(cidr))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Subnet Calculator")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Image(systemName: "grid")
                    .font(.title)
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Input Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NETWORK CONFIGURATION")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .bold()
                        
                        HStack(spacing: 16) {
                            TextField("IP Address", text: $ipAddress)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                            
                            HStack {
                                Text("/\(Int(cidr))")
                                    .font(.headline)
                                    .frame(width: 40)
                                
                                Slider(value: $cidr, in: 0...32, step: 1)
                                    .tint(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                    .cornerRadius(12)
                    
                    if let info = subnetInfo {
                        // Results Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ResultCard(title: "Network Address", value: info.networkAddress, icon: "network")
                            ResultCard(title: "Broadcast Address", value: info.broadcastAddress, icon: "antenna.radiowaves.left.and.right")
                            ResultCard(title: "Subnet Mask", value: info.mask, icon: "bolt.shield")
                            ResultCard(title: "Wildcard Mask", value: info.wildcard, icon: "seal")
                            ResultCard(title: "First Usable", value: info.firstUsable, icon: "arrow.right.circle")
                            ResultCard(title: "Last Usable", value: info.lastUsable, icon: "arrow.left.circle")
                        }
                        
                        // Summary
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Usable Hosts")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(info.totalUsable)")
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Binary visualizer
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BINARY VISUALIZER")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .bold()
                            
                            BinaryRow(label: "IP", octets: info.binaryAddress, cidr: Int(cidr))
                            BinaryRow(label: "Mask", octets: info.binaryMask, cidr: Int(cidr), isMask: true)
                        }
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(12)
                    } else {
                        ContentUnavailableView("Invalid IP Address", systemImage: "xmark.circle", description: Text("Please enter a valid IPv4 address to see calculations."))
                    }
                }
                .padding()
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.body, design: .monospaced))
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct BinaryRow: View {
    let label: String
    let octets: [String]
    let cidr: Int
    var isMask: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                ForEach(0..<4) { i in
                    HStack(spacing: 2) {
                        let bits = Array(octets[i])
                        ForEach(0..<8) { b in
                            let absoluteBit = i * 8 + b
                            Text(String(bits[b]))
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(absoluteBit < cidr ? (isMask ? .blue : .primary) : .secondary)
                                .opacity(absoluteBit < cidr ? 1.0 : 0.5)
                        }
                    }
                    if i < 3 {
                        Text(".")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

#Preview {
    SubnetCalculatorView()
        .frame(width: 600, height: 500)
}
