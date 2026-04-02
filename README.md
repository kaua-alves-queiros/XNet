# XNet› 🚀

**XNet›** is a native, high-performance macOS utility suite designed specifically for Network Operations Center (NOC) professionals and network engineers. Built 100% in Swift and SwiftUI, it provides a comprehensive set of diagnostic and remote management tools in a clean, modern interface.

[![Platform](https://img.shields.io/badge/Platform-macOS%2015.0+-blue.svg)](https://apple.com)
[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📸 Screenshots

<div align="center">
  <img src="assets/screenshots/ip_scan.png" width="400" alt="IP Scanner">
  <img src="assets/screenshots/port.png" width="400" alt="Port Scanner">
  <br>
  <img src="assets/screenshots/subnet.png" width="400" alt="Subnet Calculator">
  <img src="assets/screenshots/subnet_breakdown.png" width="400" alt="Subnet Partitioning">
  <br>
  <img src="assets/screenshots/ping.png" width="400" alt="Visual Ping">
  <img src="assets/screenshots/traceroute.png" width="400" alt="Traceroute">
  <br>
  <img src="assets/screenshots/terminal.png" width="400" alt="SSH/Telnet Terminal">
  <img src="assets/screenshots/ftp.png" width="400" alt="FTP/SFTP Client">
</div>

---

## ✨ Features

### 🔍 Diagnostics
- **IP Scanner**: High-speed discovery of devices on local and public networks with real-time status indicators.
- **Port Scanner**: Rapidly identify open services and potential vulnerabilities with service identification.
- **Visual Ping**: Real-time ICMP monitoring with high-fidelity latency statistics and history.
- **Traceroute**: Map network hops and identify routing bottlenecks with visual feedback.

### 📐 Planning & Infrastructure (NetBox)
- **NetBox Dashboard**: Integrated DCIM & IPAM for hardware inventory and global subnet management.
- **VLAN Availability Map**: Automatic mathematical calculation of free ID ranges (VLAN Rollout).
- **SwiftData Persistence**: Fully persistent local database with high-integrity relationships.

### 📐 Subnet Calculator (The Planner)
- **Advanced Calculations**: IPv4 bitwise calculations with CIDR support and VLSM partitioning.
- **Binary Visualizer**: Exact bit-level representation of the network and host portions.
- **Interactive Breakdown**: Generate and visualize usable IP ranges for any sub-partition.

### 🖥️ Remote Access & File Transfer
- **Unified Terminal**: Support for SSH, Telnet, and Native Serial/COM Port (POSIX-based) for hardware configuration.
- **FTP/SFTP Client**: Integrated file management for remote servers with a professional dual-pane experience.

---

## 🛠️ Architecture

XNet› follows a **Feature-Based Modular Architecture** for maximum scalability:
- **Core**: Shared models and low-level diagnostic engines.
- **Features**: Highly decoupled modules (Ping, NetBox, Terminal, etc.) for isolation and stability.
- **Componentized UI**: Advanced SwiftUI layouts with high-performance list rendering.

---

## 🚀 Installation & Distribution

XNet› is designed for high-precision networking tasks and is distributed as an Ad-Hoc signed DMG.

### Prerequisites
- macOS 15.0 or later.
- To build: Xcode 16.0+

### Building from Source
```bash
git clone https://github.com/kaua-alves-queiros/XNet.git
cd XNet
# Open XNet›.xcodeproj and run (Cmd + R)
```

---

## 🏗️ Tech Stack
- **Language**: Swift 6.0
- **Frameworks**: SwiftUI (Observation), SwiftData, Network.framework
- **Engines**: Raw Sockets (POSIX), Termios for Serial COM access.

---

## 🤝 Contribution
Contributions are welcome! Please feel free to open a Pull Request or Issue for new tool requests or UI improvements.

---

## 📄 License
This project is licensed under the MIT License.

---

*“Design is not just what it looks like and feels like. Design is how it works.”* – **XNet›**
