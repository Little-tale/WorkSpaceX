//
//  WorkSpaceChatEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation

struct WorkSpaceChatEntity: Entity {
    let channelId: String
    let channelName: String
    let chatId: String
    let content: String
    let createdAt: String
    let files: [String]?
    let user: WorkSpaceMemberEntity
}
