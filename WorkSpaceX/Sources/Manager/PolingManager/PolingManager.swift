//
//  PolingManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/10/24.
//

import UIKit
import ComposableArchitecture

final class PollingManager {
    static let shared = PollingManager()
    
    private init() {
        setUp()
    }
    
    private var interval: any BinaryInteger = 0
    private var action: (() async -> Void)?
    private var isPollingPaused: Bool = false
    private var continuation: AsyncStream<Void>.Continuation?
    
    func startPolling(every seconds: any BinaryInteger) -> AsyncStream<Void> {
        self.interval = seconds
        let stream = AsyncStream<Void> { continuation in
            self.continuation = continuation
            
            Task {
                while !Task.isCancelled {
                    if !self.isPollingPaused {
                        continuation.yield(())
                    }
                    try? await Task.sleep(for: .seconds(seconds))
                }
            }
        }
        return stream
    }
    
    func stopPolling() {
        continuation?.finish()
        continuation = nil
    }
    
    private func pausePolling() {
        isPollingPaused = true
    }
    
    private func resumePolling() {
        isPollingPaused = false
    }
}

extension PollingManager {
    private func setUp() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidEnterBackground() {
        pausePolling()
        print("Polling paused")
    }
    
    @objc private func applicationWillEnterForeground() {
        resumePolling()
        print("Polling resumed")
    }
}

extension PollingManager: DependencyKey {
    static var liveValue: PollingManager = PollingManager.shared
}

extension DependencyValues {
    var pollingManager: PollingManager {
        get { self[PollingManager.self] }
        set { self[PollingManager.self] = newValue }
    }
}
