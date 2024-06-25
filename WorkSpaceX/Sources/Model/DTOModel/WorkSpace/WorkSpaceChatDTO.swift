//
//  WorkSpaceChatDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation

struct WorkSpaceChatDTO: DTO {
    let channel_id: String
    let channelName: String
    let chat_id: String
    let content: String?
    let createdAt: String
    let files: [String]?
    let user: WorkSpaceAddMemberDTO
}
