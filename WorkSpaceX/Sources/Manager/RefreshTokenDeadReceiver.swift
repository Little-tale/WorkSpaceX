//
//  RefreshTokenDeadReceiver.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation

final class RefreshTokenDeadReceiver {
    
    static let shared = RefreshTokenDeadReceiver()
    
    private init() {}
    
    func postRefreshTokenDead() {
        UserDefaultsManager.workSpaceSelectedID = ""
        UserDefaultsManager.accessToken = nil
        UserDefaultsManager.ifEmailLogin = false
        NotificationCenter.default.post(name: .refreshTokenDead, object: nil)
    }
    
}

extension Notification.Name {
    static let refreshTokenDead = Notification.Name("refreshTokenDead")
}
