//
//  WorkSpaceChanelsDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation

struct WorkSpaceChanelsDTO: DTO {
    let channel_id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner_id: String
    let createdAt: String
}
