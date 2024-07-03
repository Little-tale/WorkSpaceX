//
//  RefreshTokkenDeadReciver.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation

final class RefreshTokkenDeadReciver {
    
    static let shared = RefreshTokkenDeadReciver()
    
    private init() {}
    
    func postRefreshTokenDead() {
        UserDefaultsManager.workSpaceSelectedID = ""
        UserDefaultsManager.accessToken = nil
        
        NotificationCenter.default.post(name: .refreshTokenDead, object: nil)
    }
    
}

extension Notification.Name {
    static let refreshTokenDead = Notification.Name("refreshTokenDead")
}
