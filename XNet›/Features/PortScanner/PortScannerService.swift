//
//  PortScannerService.swift
//  XNet›
//

import Foundation
import Network

class PortScannerService {
    static func scan(host: String, ports: [Int], timeout: TimeInterval = 1.0) -> AsyncStream<ScannedPort> {
        return AsyncStream { continuation in
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "com.xnet.portscan", qos: .userInitiated, attributes: .concurrent)
            
            for port in ports {
                group.enter()
                queue.async {
                    let endpoint = NWEndpoint.Host(host)
                    let p = NWEndpoint.Port(rawValue: UInt16(port))!
                    let connection = NWConnection(host: endpoint, port: p, using: .tcp)
                    
                    let finishedFlag = CancelFlag()
                    
                    connection.stateUpdateHandler = { state in
                        // finishedFlag is @unchecked Sendable, it is safe to access
                        if finishedFlag.isCancelled { return }
                        switch state {
                        case .ready:
                            finishedFlag.isCancelled = true
                            continuation.yield(ScannedPort(port: port, protocolName: "TCP", state: "Open"))
                            connection.cancel()
                            group.leave()
                        case .failed(_), .waiting(_):
                             finishedFlag.isCancelled = true
                             connection.cancel()
                             group.leave()
                        default:
                            break
                        }
                    }
                    
                    connection.start(queue: .global())
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                        if !finishedFlag.isCancelled {
                            finishedFlag.isCancelled = true
                            connection.cancel()
                            group.leave()
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                continuation.finish()
            }
        }
    }
}
