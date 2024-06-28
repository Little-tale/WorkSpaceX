//
//  WorkSpaceChannelEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/27/24.
//

import Foundation

struct WorkSpaceChannelEntity: Entity {
    var channelID: String
    
    var name: String
    
    var introduce: String
    
    var coverImage: String?
    
    var ownerID: String
    
    var createdAt: Date?
    
    var didNotReadCount: Int
    
//     var chatMessages: [WorkSpaceChatEntity]
}
