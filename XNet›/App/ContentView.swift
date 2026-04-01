//
//  ContentView.swift
//  XNet›
//
//  Created by kaua on 28/03/26.
//

import SwiftUI

struct ContentView: View {
    // Estado para controlar a seleção na barra lateral
    @State private var selection: Tool? = .devices

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                
                // SEÇÃO DE CADASTROS (INVENTORY)
                Section("Inventory") {
                    NavigationLink(value: Tool.devices) {
                        Label(Tool.devices.name, systemImage: Tool.devices.icon)
                    }
                    NavigationLink(value: Tool.deviceGroups) {
                        Label(Tool.deviceGroups.name, systemImage: Tool.deviceGroups.icon)
                    }
                }
                
                // SEÇÃO DE DIAGNÓSTICO (DIAGNOSTICS)
                Section("Diagnostics") {
                    ForEach([Tool.ipScan, Tool.portScan, Tool.ping, Tool.traceroute], id: \.self) { tool in
                        NavigationLink(value: tool) {
                            Label(tool.name, systemImage: tool.icon)
                        }
                    }
                }
                
                // SEÇÃO DE ACESSO REMOTO (REMOTE ACCESS)
                Section("Remote Access") {
                    ForEach([Tool.terminal, Tool.ftp], id: \.self) { tool in
                        NavigationLink(value: tool) {
                            Label(tool.name, systemImage: tool.icon)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("XNet")
            .frame(minWidth: 200)
            
        } detail: {
            // Área de conteúdo que muda conforme a seleção
            if let tool = selection {
                DetailContentView(tool: tool)
            } else {
                ContentUnavailableView("Select a Tool",
                                     systemImage: "sidebar.left",
                                     description: Text("Choose a tool from the sidebar to get started."))
            }
        }
    }
}

// Preview para o Xcode
#Preview {
    ContentView()
}
