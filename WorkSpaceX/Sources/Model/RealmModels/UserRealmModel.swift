//
//  UserRealmModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation
import RealmSwift

class UserRealmModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var userID: String // 서버에서 주는 아이덴티 키를 사용해야함.
    @Persisted var email: String
    @Persisted var nickName: String
    @Persisted var profileImage: String?
    @Persisted var phone: String?
    @Persisted var provider: String?
    @Persisted var createdAt: Date?
    
    
    convenience
    init(userID: String, email: String, nickName: String, profileImage: String? = nil, phone: String? = nil, provider: String? = nil, createdAt: Date? = nil) {
        self.init()
        self.userID = userID
        self.email = email
        self.nickName = nickName
        self.profileImage = profileImage
        self.phone = phone
        self.provider = provider
        self.createdAt = createdAt
    }
    
}
