//
//  DMSRoomRealmModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import RealmSwift

class DMSRoomRealmModel: Object {
    
    @Persisted(primaryKey: true) var roomId: String
    // 포리너 키
    @Persisted var workSpaceID: String 
    
    @Persisted var createdAt: String
    
    @Persisted var userID: String
    
    @Persisted var email: String
    
    @Persisted var nickName: String
    
    @Persisted var profileImage: String?
    
    convenience
    init(roomId: String, createdAt: String, userID: String, email: String, nickName: String, profileImage: String? = nil) {
        self.init()
        self.roomId = roomId
        self.createdAt = createdAt
        self.userID = userID
        self.email = email
        self.nickName = nickName
        self.profileImage = profileImage
    }
    
}
