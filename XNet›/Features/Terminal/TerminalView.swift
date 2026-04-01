//
//  TerminalView.swift
//  XNet›
//

import SwiftUI

struct TerminalView: View {
    @State private var connectionType: ConnectionType = .ssh
    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var username: String = ""
    @State private var commandInput: String = ""
    
    @State private var manager = TerminalConnectionManager()
    
    enum ConnectionType: String, CaseIterable, Identifiable {
        case ssh = "SSH"
        case telnet = "Telnet"
        case serial = "COM Port"
        
        var id: String { self.rawValue }
    }
    
    @State private var availableSerialPorts: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Configuration Bar
            VStack(spacing: 12) {
                HStack {
                    Text("Terminal")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                
                HStack {
                    Picker("Protocol", selection: $connectionType) {
                        ForEach(ConnectionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                    .onChange(of: connectionType) { _, newValue in
                        updateDefaultPort(for: newValue)
                    }
                    .onAppear {
                        if connectionType == .serial {
                            availableSerialPorts = manager.getAvailableSerialPorts()
                        }
                    }

                    Spacer()
                }
                
                HStack(spacing: 16) {
                    if connectionType == .serial {
                        Picker("Port", selection: $host) {
                            if availableSerialPorts.isEmpty {
                                Text("No serial ports found").tag("")
                            } else {
                                ForEach(availableSerialPorts, id: \.self) { p in
                                    Text(p.replacingOccurrences(of: "/dev/cu.", with: "")).tag(p)
                                }
                            }
                        }
                        .frame(width: 200)
                        .disabled(manager.isConnected)
                        
                        Picker("Baud Rate", selection: $port) {
                            ForEach(["9600", "19200", "38400", "57600", "115200", "230400", "921600"], id: \.self) { rate in
                                Text(rate).tag(rate)
                            }
                        }
                        .frame(width: 140)
                        .disabled(manager.isConnected)
                    } else {
                        TextField("Host or IP", text: $host)
                            .textFieldStyle(.roundedBorder)
                            .disabled(manager.isConnected)
                        
                        TextField("Port", text: $port)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .disabled(manager.isConnected)
                        
                        if connectionType == .ssh {
                            TextField("Username", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 150)
                                .disabled(manager.isConnected)
                        }
                    }
                    
                    Button(action: toggleConnection) {
                        Label(manager.isConnected ? "Disconnect" : "Connect", systemImage: manager.isConnected ? "stop.fill" : "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(manager.isConnected ? .red : .blue)
                    .disabled(host.isEmpty)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Terminal Area
            ZStack(alignment: .topLeading) {
                Color.black
                
                if manager.isConnected {
                    InteractiveTerminalTextView(text: $manager.logs) { input in
                        manager.sendRaw(input)
                    }
                } else {
                    ScrollView {
                        Text(manager.logs)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Terminal")
        .onDisappear {
            manager.disconnect()
        }
    }
    
    private func updateDefaultPort(for type: ConnectionType) {
        switch type {
        case .ssh:
            port = "22"
        case .telnet:
            port = "23"
        case .serial:
            port = "115200"
            availableSerialPorts = manager.getAvailableSerialPorts()
            if let first = availableSerialPorts.first, host.isEmpty || !availableSerialPorts.contains(host) {
                host = first
            } else if availableSerialPorts.isEmpty {
                host = ""
            }
        }
    }
    
    private func toggleConnection() {
        if manager.isConnected {
            manager.disconnect()
        } else {
            // Clear logs before connecting
            manager.logs = ""
            if connectionType == .ssh {
                manager.connectSSH(host: host, port: port, user: username)
            } else if connectionType == .telnet {
                manager.connectTelnet(host: host, port: port)
            } else if connectionType == .serial {
                if let baudRate = Int(port) {
                    manager.connectSerial(portPath: host, baudRate: baudRate)
                }
            }
        }
    }
    
    private func sendCommand() {
        guard !commandInput.isEmpty else { return }
        manager.logs += "> \(commandInput)\n"
        manager.sendCommand(commandInput)
        commandInput = ""
    }
}

#Preview {
    TerminalView()
}
