//
//  DMSChatDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct DMSChatDTO: DTO {
    let dm_id: String
    let room_id: String
    let content: String?
    let createdAt: String
    let files: [String]?
    let user: WorkSpaceAddMemberDTO
}
