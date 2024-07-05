//
//  SearchResultDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

struct SearchResultDTO: DTO {
    let workspace_id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner_id, createdAt: String
    let channels: [SearchChannelDTO]
    let workspaceMembers: [WorkSpaceAddMemberDTO]
}
