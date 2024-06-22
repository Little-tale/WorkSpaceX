//
//  WorkSpaceChannelRealmModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation
import RealmSwift

class WorkSpaceChannelRealmModel: Object {
    
    @Persisted(primaryKey: true) var channelID: String
    
    @Persisted var name: String
    
    @Persisted var introduce: String
    
    @Persisted var coverImage: String?
    
    @Persisted var ownerID: String
    
    @Persisted var createdAt: Date?
    
    @Persisted var didNotReadCount: Int
    
    @Persisted var chatMessages = List<ChatRealmModel>()
    
    convenience
    init(channelID: String, name: String, introduce: String, coverImage: String? = nil, ownerID: String, createdAt: Date? = nil) {
        self.init()
        self.channelID = channelID
        self.name = name
        self.introduce = introduce
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.didNotReadCount = 0
    }
}

