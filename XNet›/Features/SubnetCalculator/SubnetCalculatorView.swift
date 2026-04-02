//
//  SubnetCalculatorView.swift
//  XNet›
//

import SwiftUI

struct SubnetCalculatorView: View {
    @State private var ipAddress: String = "192.168.1.0/24"
    @State private var service = SubnetCalculatorService()
    
    @State private var selectedCidrForBreakdown: Int? = nil
    
    private var subnetInfo: SubnetInfo? {
        let parts = ipAddress.split(separator: "/")
        let ip = String(parts.first ?? "")
        let cidr = parts.count > 1 ? (Int(parts[1]) ?? 24) : 24
        return service.calculate(address: ip, cidr: cidr)
    }
    
    private var breakdownSubnets: [String] {
        guard let info = subnetInfo, let target = selectedCidrForBreakdown else { return [] }
        return service.generateSubnets(baseIp: info.networkAddress, currentCidr: info.cidr, targetCidr: target)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            ScrollView {
                VStack(spacing: 32) {
                    if let info = subnetInfo {
                        overviewSection(info: info)
                        binaryVisualizerSection(info: info)
                        partitioningSection(info: info)
                        if let selectedCidr = selectedCidrForBreakdown {
                            breakdownListSection(selectedCidr: selectedCidr)
                        }
                    } else {
                        ContentUnavailableView("Invalid Format", systemImage: "text.badge.xmark", description: Text("Please enter a valid IPv4 address and CIDR (e.g. 192.168.1.0/24)."))
                    }
                }
                .padding(28)
            }
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        }
        .navigationTitle("IP Calculator")
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Subnet Calculator")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Network segmentation and advanced CIDR breakdown")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "square.grid.3x2.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "network")
                        .foregroundStyle(.blue)
                        .font(.system(size: 14, weight: .semibold))
                    TextField("IPv4 Address or Subnet (e.g., 192.168.1.0/24)", text: $ipAddress)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func overviewSection(info: SubnetInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUBNET IDENTITY")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ResultCard(title: "Network Address", value: info.networkAddress, icon: "sitemap")
                ResultCard(title: "Broadcast Address", value: info.broadcastAddress, icon: "antenna.radiowaves.left.and.right")
                ResultCard(title: "Subnet Mask", value: info.mask, icon: "shield.righthalf.filled")
                ResultCard(title: "Wildcard Mask", value: info.wildcard, icon: "wand.and.stars")
                ResultCard(title: "First Usable IP", value: info.firstUsable, icon: "arrow.right.circle.fill")
                ResultCard(title: "Last Usable IP", value: info.lastUsable, icon: "arrow.left.circle.fill")
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Usable Hosts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(String(info.totalUsable))
                        .font(.system(size: 24, design: .monospaced))
                        .bold()
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "server.rack")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue.opacity(0.2), lineWidth: 1))
        }
    }
    
    private func binaryVisualizerSection(info: SubnetInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BINARY VISUALIZER")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)
            
            VStack(spacing: 0) {
                BinaryRow(label: "IP", octets: info.binaryAddress, cidr: info.cidr)
                Divider().padding(.vertical, 12)
                BinaryRow(label: "Mask", octets: info.binaryMask, cidr: info.cidr, isMask: true)
            }
            .padding(20)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: 1))
        }
    }
    
    private func partitioningSection(info: SubnetInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUBNET PARTITIONING (VLSM)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)
            
            let currentCidr = info.cidr
            if currentCidr < 32 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach((currentCidr + 1)...32, id: \.self) { targetCidr in
                            let count = Int(pow(2.0, Double(targetCidr - currentCidr)))
                            let isSelected = selectedCidrForBreakdown == targetCidr
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCidrForBreakdown = targetCidr
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text("/\(targetCidr)")
                                        .font(.system(.headline, design: .monospaced))
                                        .foregroundStyle(isSelected ? .white : .primary)
                                    Text("\(count) subnets")
                                        .font(.system(size: 10))
                                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(isSelected ? Color.blue : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                Text("No sub-partitioning possible for a /32 host address.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func breakdownListSection(selectedCidr: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUBNET BREAKDOWN (/\(selectedCidr))")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)
            
            VStack(spacing: 0) {
                ForEach(Array(breakdownSubnets.enumerated()), id: \.element) { index, subnet in
                    SubnetBreakdownRow(
                        subnet: subnet,
                        selectedCidr: selectedCidr,
                        service: service,
                        isAlternating: index % 2 != 0,
                        showDivider: index < breakdownSubnets.count - 1
                    )
                }
            }
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: 1))
        }
    }
}

struct SubnetBreakdownRow: View {
    let subnet: String
    let selectedCidr: Int
    let service: SubnetCalculatorService
    let isAlternating: Bool
    let showDivider: Bool
    
    private var subInfo: SubnetInfo? {
        service.calculate(address: String(subnet.split(separator: "/")[0]), cidr: selectedCidr)
    }
    
    private var ipList: [String] {
        service.getUsableIPs(address: String(subnet.split(separator: "/")[0]), cidr: selectedCidr)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(subnet)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                    Spacer()
                    Text("\(subInfo?.totalUsable ?? 0) Hosts")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ipList, id: \.self) { ip in
                            Text(ip)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(ip.contains("...") ? .secondary : .primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.05), lineWidth: 1))
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isAlternating ? Color(NSColor.alternatingContentBackgroundColors[1]).opacity(0.5) : Color.clear)
            
            if showDivider {
                Divider()
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.body, design: .monospaced))
                .bold()
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: 1))
    }
}

struct BinaryRow: View {
    let label: String
    let octets: [String]
    let cidr: Int
    var isMask: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(0..<4) { i in
                    HStack(spacing: 2) {
                        let bits = Array(octets[i])
                        ForEach(0..<8) { b in
                            let absoluteBit = i * 8 + b
                            Text(String(bits[b]))
                                .font(.system(size: 15, design: .monospaced))
                                .bold()
                                .foregroundStyle(absoluteBit < cidr ? (isMask ? .blue : .primary) : .secondary)
                                .opacity(absoluteBit < cidr ? 1.0 : 0.4)
                        }
                    }
                    if i < 3 {
                        Text(".")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            Spacer()
        }
    }
}
