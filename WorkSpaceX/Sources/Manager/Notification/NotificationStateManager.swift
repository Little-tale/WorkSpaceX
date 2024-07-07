//
//  NotificationStateManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/7/24.
//

import UserNotifications
import UIKit
import ComposableArchitecture

@MainActor
final class NotificationStateManager: ObservableObject {
    static let shared = NotificationStateManager()
    
    private init() {}
    
    func notificationSettingsStream() -> AsyncStream<UNAuthorizationStatus> {
        return AsyncStream { continuation in
            let center = UNUserNotificationCenter.current()
            
            let updateSettings = {
                center.getNotificationSettings { settings in
                    continuation.yield(settings.authorizationStatus)
                }
            }
            
            updateSettings()
            
            let notification = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil
            ) { _ in
                updateSettings()
            }
            
            continuation.onTermination = { @Sendable _ in
                NotificationCenter.default.removeObserver(notification)
            }
        }
    }
}

extension NotificationStateManager: DependencyKey {
    static var liveValue: NotificationStateManager = NotificationStateManager.shared
}

extension DependencyValues {
    var notificationStateManager: NotificationStateManager {
        get { self[NotificationStateManager.self] }
        set { self[NotificationStateManager.self] = newValue }
    }
}
