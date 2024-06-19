//
//  WorkSpaceEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

struct WorkSpaceEntity: Entity {
    let workSpaceID: String
    let name: String
    let description: String?
    let coverImage: URL?
    let ownerID: String
    let createdAt: String
    
    var chanelEntitys: [ChanelEntity]
    var workSpaceMembersEntitys : [WorkSpaceMembersEntity]
    
    init(workSpaceID: String, name: String, description: String?, coverImage: URL?, ownerID: String, createdAt: String) {
        self.workSpaceID = workSpaceID
        self.name = name
        self.description = description
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.chanelEntitys = []
        self.workSpaceMembersEntitys = []
    }
    
    init(workSpaceID: String, name: String, description: String?, coverImage: URL?, ownerID: String, createdAt: String, ChanelEntitys: [ChanelEntity], WorkSpaceMembersEntitys: [WorkSpaceMembersEntity]) {
        self.workSpaceID = workSpaceID
        self.name = name
        self.description = description
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.chanelEntitys = ChanelEntitys
        self.workSpaceMembersEntitys = WorkSpaceMembersEntitys
    }
}
