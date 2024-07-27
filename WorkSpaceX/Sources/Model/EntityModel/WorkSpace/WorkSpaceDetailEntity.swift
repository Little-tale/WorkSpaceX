//
//  WorkSpaceDetailEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import Foundation


struct WorkSpaceDetailEntity: Entity {
    
    let workSpaceID: String
    let name: String
    let description: String?
    let coverImage: URL?
    let ownerID: String
    let createdAt: String
    
    var channelEntities: [ChanelEntity]
    var workSpaceMembersEntities : [WorkSpaceMembersEntity]
    
    init(workSpaceID: String, name: String, description: String?, coverImage: URL?, ownerID: String, createdAt: String, channelEntities: [ChanelEntity], workSpaceMembersEntities: [WorkSpaceMembersEntity]) {
        self.workSpaceID = workSpaceID
        self.name = name
        self.description = description
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.channelEntities = channelEntities
        self.workSpaceMembersEntities = workSpaceMembersEntities
    }
}


