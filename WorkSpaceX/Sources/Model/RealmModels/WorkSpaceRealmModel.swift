//
//  WorkSpaceRealmModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import RealmSwift

class WorkSpaceRealmModel: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var workSpaceID: String
    @Persisted var workSpaceName: String
    @Persisted var introduce: String?
    @Persisted var coverImage: String?
    @Persisted var ownerID: String
    @Persisted var createdAt: Date?
    
    @Persisted var users: List<UserRealmModel>
    
    convenience
    init(
        workSpaceID: String,
        workSpaceName: String,
        introduce: String? = nil,
        coverImage: String? = nil,
        ownerID: String,
        createdAt: Date? = nil,
        users: [UserRealmModel]
    ) {
        
        self.init()
        
        self.workSpaceID = workSpaceID
        self.workSpaceName = workSpaceName
        self.introduce = introduce
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.users.append(objectsIn: users)
    }
    
}
