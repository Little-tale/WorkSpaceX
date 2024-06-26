//
//  ChatModeEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import Foundation

struct ChatModeEntity: Entity {
    
    let chatID: String
    
    enum isME: Equatable, Hashable {
        case me
        case other(WorkSpaceMemberEntity) // 타유저
    }
    
    var isMe: isME
    /// iF NIL -> ""
    var content: String
    /// IF NIL -> []
    
    var files: [String]
    var date: Date
    var isFirstDate: Bool
}
