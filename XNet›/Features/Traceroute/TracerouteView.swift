//
//  TracerouteView.swift
//  XNet›
//

import SwiftUI

struct TracerouteView: View {
    @State private var tracerouteService = TracerouteService()
    @State private var targetHost: String = "google.com"
    @State private var hops: [TracerouteHop] = []
    @State private var isRunning = false
    @State private var currentTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Text("Traceroute")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding([.top, .horizontal])
            
            HStack {
                TextField("Address (e.g. google.com)", text: $targetHost)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isRunning)
                
                Button(action: {
                    if isRunning {
                        stopTrace()
                    } else {
                        startTrace()
                    }
                }) {
                    Text(isRunning ? "Stop" : "Start")
                        .frame(width: 80)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            
            Table(hops) {
                TableColumn("Hop") { hop in
                    Text("\(hop.id)")
                        .foregroundColor(.secondary)
                }
                .width(40)
                
                TableColumn("IP Address") { hop in
                    Text(hop.ip)
                        .font(.system(.body, design: .monospaced))
                }
                
                TableColumn("Time 1") { hop in Text(hop.time1) }
                TableColumn("Time 2") { hop in Text(hop.time2) }
                TableColumn("Time 3") { hop in Text(hop.time3) }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            
            HStack {
                Text(isRunning ? "Tracing native route to \(targetHost)..." : "Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Traceroute")
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
