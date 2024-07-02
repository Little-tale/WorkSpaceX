//
//  DMSChatEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct DMSChatEntity: Entity {
    let dmID: String
    let roomID: String
    let content: String?
    let createdAt: String
    let files: [String]?
    let user: WorkSpaceMembersEntity
}
