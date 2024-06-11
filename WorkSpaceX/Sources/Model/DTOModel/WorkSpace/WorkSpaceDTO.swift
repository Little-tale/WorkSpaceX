//
//  WorkSpaceDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

struct WorkSpaceDTO: DTO {
    let workspace_id: String
    let name: String
    let description: String?
    let coverImage: String
    let owner_id: String
    let createdAt: String
}

