import SwiftUI

struct TerminalSidebarView: View {
    @Binding var savedDevices: [XNetTerminalDevice]
    @Binding var expandedGroups: Set<String>
    @Binding var deviceSearch: String
    @Binding var selectedDeviceID: UUID?
    
    let theme: TerminalTheme
    let groupedFilteredSavedDevices: [(group: String, devices: [XNetTerminalDevice])]
    
    var onToggleGroup: (String) -> Void
    var onEditDevice: (XNetTerminalDevice) -> Void
    var onConnectDevice: (XNetTerminalDevice) -> Void
    var onOpenNewTab: (XNetTerminalDevice) -> Void
    var onDeleteDevice: (XNetTerminalDevice) -> Void
    var onAddNewDevice: () -> Void
    var onAddNewGroup: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            searchBar
            deviceList
        }
        .frame(width: 300)
        .background(
            LinearGradient(
                colors: [theme.sidebarTopColor, theme.sidebarBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var header: some View {
        HStack {
            Text("Dispositivos Salvos")
                .font(.headline)
                .foregroundStyle(theme.foregroundColor)
            Text("\(savedDevices.count)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.mutedColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.95 : 0.68))
                .clipShape(Capsule())
            Spacer()
            Button(action: onAddNewDevice) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            
            Button(action: onAddNewGroup) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.mutedColor)
            TextField("Buscar host, IP ou usuário", text: $deviceSearch)
                .textFieldStyle(.plain)
                .foregroundStyle(theme.foregroundColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.95 : 0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.top, 10)
    }
    
    private var deviceList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(groupedFilteredSavedDevices, id: \.group) { groupItem in
                    VStack(spacing: 6) {
                        groupHeader(groupItem)
                        
                        if expandedGroups.contains(groupItem.group) {
                            VStack(spacing: 8) {
                                ForEach(groupItem.devices) { device in
                                    XNetTerminalDeviceRow(
                                        device: device,
                                        selectedDeviceID: $selectedDeviceID,
                                        theme: theme,
                                        onEdit: { onEditDevice(device) },
                                        onConnect: { onConnectDevice(device) },
                                        onOpenNewTab: { onOpenNewTab(device) },
                                        onDelete: { onDeleteDevice(device) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
    }
    
    private func groupHeader(_ groupItem: (group: String, devices: [XNetTerminalDevice])) -> some View {
        Button {
            onToggleGroup(groupItem.group)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: expandedGroups.contains(groupItem.group) ? "folder.fill" : "folder")
                    .foregroundStyle(theme.mutedColor)
                Text(groupItem.group)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.foregroundColor)
                Text("\(groupItem.devices.count)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.mutedColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.9 : 0.7))
                    .clipShape(Capsule())
                Spacer()
                Image(systemName: expandedGroups.contains(groupItem.group) ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.mutedColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(theme.cardBackgroundColor.opacity(theme.isLight ? 0.9 : 0.52))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct XNetTerminalDeviceRow: View {
    let device: XNetTerminalDevice
    @Binding var selectedDeviceID: UUID?
    let theme: TerminalTheme
    
    var onEdit: () -> Void
    var onConnect: () -> Void
    var onOpenNewTab: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            icon
            
            VStack(alignment: .leading, spacing: 3) {
                Text(device.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.foregroundColor)
                    .lineLimit(1)
                Text("\(device.connectionType.lowercased()), \(device.username.isEmpty ? "sem user" : device.username)")
                    .font(.system(size: 10))
                    .foregroundStyle(theme.mutedColor)
                Text("\(device.host):\(device.port)")
                    .font(.system(size: 10))
                    .foregroundStyle(theme.mutedColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedDeviceID = device.id
            }
            
            actions
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(selectedDeviceID == device.id ? theme.accentColor.opacity(theme.isLight ? 0.14 : 0.18) : theme.cardBackgroundColor.opacity(theme.isLight ? 0.82 : 0.32))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selectedDeviceID == device.id ? theme.accentColor.opacity(0.55) : theme.panelBorderColor.opacity(theme.isLight ? 0.3 : 0.45), lineWidth: 1)
        )
        .contextMenu {
            Button("Editar", action: onEdit)
            Button("Conectar", action: onOpenNewTab)
            Button("Excluir", role: .destructive, action: onDelete)
        }
    }
    
    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.accentColor.opacity(theme.isLight ? 0.16 : 0.24))
                .frame(width: 28, height: 28)
            Image(systemName: "terminal")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.accentColor)
        }
    }
    
    private var actions: some View {
        HStack(spacing: 4) {
            Button(action: onEdit) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 10, weight: .bold))
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            
            Button(action: onConnect) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10, weight: .bold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
        }
    }
}
