//
//  SearchChannelDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation


struct SearchChannelDTO: DTO {
    let channel_id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner_id: String
    let createdAt: String
}
