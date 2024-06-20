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
    
    init(workSpaceID: String, name: String, description: String?, coverImage: URL?, ownerID: String, createdAt: String) {
        self.workSpaceID = workSpaceID
        self.name = name
        self.description = description
        self.coverImage = coverImage
        self.ownerID = ownerID
        self.createdAt = createdAt
    }
}
