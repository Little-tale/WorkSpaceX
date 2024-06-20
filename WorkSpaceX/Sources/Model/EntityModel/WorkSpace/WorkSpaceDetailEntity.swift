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
    
    var chanelEntitys: [ChanelEntity]
    var workSpaceMembersEntitys : [WorkSpaceMembersEntity]
    
    init(workSpaceID: String, name: String, description: String?, coverImage: URL?, ownerID: String, createdAt: String, chanelEntitys: [ChanelEntity], workSpaceMembersEntitys: [WorkSpaceMembersEntity]) {
        self.workSpaceID = workSpaceID
        self.name = name
        self.description = description
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.chanelEntitys = chanelEntitys
        self.workSpaceMembersEntitys = workSpaceMembersEntitys
    }
}


