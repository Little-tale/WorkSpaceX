//
//  WorkSpaceChanelInfoDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation

struct WorkSpaceChanelInfoDTO: DTO {
    let channel_id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner_id: String
    let createdAt: String
    let channelMembers: [WorkSpaceAddMemberDTO]
}
