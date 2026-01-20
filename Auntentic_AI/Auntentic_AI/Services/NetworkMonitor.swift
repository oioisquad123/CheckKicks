//
//  NetworkMonitor.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 18: Network connectivity monitoring
//

import Foundation
import Network
import OSLog
import SwiftUI

/// Monitors network connectivity using NWPathMonitor
@Observable
final class NetworkMonitor {

    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Properties

    /// Whether the device is connected to the network
    var isConnected: Bool = true

    /// The current connection type
    var connectionType: ConnectionType = .unknown

    /// Whether the connection is expensive (cellular data)
    var isExpensive: Bool = false

    /// Whether the connection is constrained (Low Data Mode)
    var isConstrained: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.auntentic.networkmonitor")
    private let logger = Logger(subsystem: "com.checkkicks.app", category: "Network")

    // MARK: - Connection Type

    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case unknown = "Unknown"

        var icon: String {
            switch self {
            case .wifi:
                return "wifi"
            case .cellular:
                return "antenna.radiowaves.left.and.right"
            case .ethernet:
                return "cable.connector"
            case .unknown:
                return "network.slash"
            }
        }
    }

    // MARK: - Initialization

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateStatus(path: path)
            }
        }
        monitor.start(queue: queue)
        logger.info("📡 Network monitoring started")
    }

    private func stopMonitoring() {
        monitor.cancel()
        logger.info("📡 Network monitoring stopped")
    }

    private func updateStatus(path: NWPath) {
        let wasConnected = isConnected
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }

        // Log status changes
        if wasConnected != isConnected {
            if isConnected {
                logger.info("✅ Network connected via \(self.connectionType.rawValue)")
            } else {
                logger.warning("⚠️ Network disconnected")
            }
        }
    }

    // MARK: - Public Methods

    /// Wait for network connectivity with timeout
    /// - Parameter timeout: Maximum time to wait in seconds
    /// - Returns: True if connected within timeout, false otherwise
    func waitForConnection(timeout: TimeInterval = 10) async -> Bool {
        if isConnected {
            return true
        }

        logger.info("⏳ Waiting for network connection...")

        let startTime = Date()
        while !isConnected {
            if Date().timeIntervalSince(startTime) > timeout {
                logger.warning("⏰ Network connection timeout")
                return false
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        return true
    }

    /// Check if network is suitable for large uploads
    var isSuitableForUpload: Bool {
        isConnected && !isConstrained
    }
}

// MARK: - Environment Key

private struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue = NetworkMonitor.shared
}

extension EnvironmentValues {
    var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}
