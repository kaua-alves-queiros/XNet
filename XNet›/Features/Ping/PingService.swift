//
//  PingService.swift
//  XNet›
//

import Foundation
import Darwin

class PingService {
    
    // ICMP structure for manual packet construction
    struct ICMPHeader {
        var type: UInt8
        var code: UInt8
        var checksum: UInt16
        var identifier: UInt16
        var sequence: UInt16
    }
    
    func ping(host: String) -> AsyncStream<PingResult> {
        let address = self.resolve(host: host)
        let cancelFlag = CancelFlag()
        
        return AsyncStream { continuation in
            guard let resolvedAddress = address else {
                continuation.finish()
                return
            }
            
            let sockID = Darwin.socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)
            if sockID < 0 {
                continuation.finish()
                return
            }
            
            // Bind the socket to INADDR_ANY and port 0 to let the kernel assign a port.
            // For SOCK_DGRAM ICMP sockets, the local port number IS the ICMP identifier.
            var localAddr = sockaddr_in()
            localAddr.sin_family = sa_family_t(AF_INET)
            localAddr.sin_port = 0 // Let kernel assign
            localAddr.sin_addr.s_addr = INADDR_ANY
            
            _ = withUnsafePointer(to: &localAddr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.bind(sockID, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            
            var boundAddr = sockaddr_in()
            var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)
            _ = withUnsafeMutablePointer(to: &boundAddr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.getsockname(sockID, $0, &addrLen)
                }
            }
            
            // The assigned port is exactly the ICMP identifier the kernel expects.
            // Using this avoids the kernel rewriting the packet and ruining our checksum.
            let identifier = UInt16(bigEndian: boundAddr.sin_port)
            
            let queue = DispatchQueue(label: "com.xnet.ping", qos: .utility)
            queue.async {
                var sequence: UInt16 = 0
                while !cancelFlag.isCancelled {
                    let startTime = Date()
                    sequence += 1
                    
                    var header = ICMPHeader(
                        type: 8,
                        code: 0,
                        checksum: 0,
                        identifier: identifier.bigEndian,
                        sequence: sequence.bigEndian
                    )
                    
                    let payloadData = "XNet Native".data(using: .utf8)!
                    let packetSize = MemoryLayout<ICMPHeader>.size + payloadData.count
                    var packet = Data(count: packetSize)
                    
                    // Simple checksum calculation without 'self' capture
                    header.checksum = 0
                    packet.replaceSubrange(0..<MemoryLayout<ICMPHeader>.size, with: Data(bytes: &header, count: MemoryLayout<ICMPHeader>.size))
                    packet.replaceSubrange(MemoryLayout<ICMPHeader>.size..<packetSize, with: payloadData)
                    
                    header.checksum = PingService.calculateChecksum(data: packet).bigEndian
                    packet.replaceSubrange(0..<MemoryLayout<ICMPHeader>.size, with: Data(bytes: &header, count: MemoryLayout<ICMPHeader>.size))
                    
                    var addr = sockaddr_in()
                    addr.sin_family = sa_family_t(AF_INET)
                    addr.sin_addr.s_addr = resolvedAddress
                    addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                    
                    let sentRes = withUnsafePointer(to: &addr) {
                        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                            Darwin.sendto(sockID, (packet as NSData).bytes, packet.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                        }
                    }
                    
                    if sentRes >= 0 {
                        var buffer = [UInt8](repeating: 0, count: 1024)
                        var from = sockaddr()
                        var fromLen = socklen_t(MemoryLayout<sockaddr>.size)
                        var timeoutValue = timeval(tv_sec: 1, tv_usec: 0)
                        Darwin.setsockopt(sockID, SOL_SOCKET, SO_RCVTIMEO, &timeoutValue, socklen_t(MemoryLayout<timeval>.size))
                        
                        let recvSize = Darwin.recvfrom(sockID, &buffer, buffer.count, 0, &from, &fromLen)
                        if recvSize >= 0 {
                            let duration = Date().timeIntervalSince(startTime) * 1000
                            continuation.yield(PingResult(
                                sequence: Int(sequence),
                                ip: host,
                                bytes: recvSize,
                                ttl: 64,
                                time: duration
                            ))
                        }
                    }
                    
                    Thread.sleep(forTimeInterval: 1.0)
                }
                Darwin.close(sockID)
            }
            
            continuation.onTermination = { @Sendable _ in
                cancelFlag.isCancelled = true
            }
        }
    }
    
    private func resolve(host: String) -> in_addr_t? {
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_DGRAM
        
        var res: UnsafeMutablePointer<addrinfo>?
        if getaddrinfo(host, nil, &hints, &res) == 0 {
            let addr = res!.pointee.ai_addr!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr.s_addr }
            freeaddrinfo(res)
            return addr
        }
        return nil
    }
    
    private static func calculateChecksum(data: Data) -> UInt16 {
        let count = data.count
        var checksum: UInt32 = 0
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            let ptr = bytes.bindMemory(to: UInt16.self)
            for i in 0..<count/2 {
                checksum += UInt32(ptr[i])
            }
            if count % 2 == 1 {
                checksum += UInt32(data[count - 1])
            }
        }
        while (checksum >> 16) != 0 {
            checksum = (checksum & 0xFFFF) + (checksum >> 16)
        }
        return UInt16(truncatingIfNeeded: ~checksum)
    }
}
