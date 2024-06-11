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
}
