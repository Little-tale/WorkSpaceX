//
//  ChatModeEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//


import Foundation

enum isME: Equatable, Hashable {
    case me
    case other(WorkSpaceMembersEntity) // 타유저
}

struct ChatModeEntity: Entity {
    let testID = UUID()
    let chatID: String
    
    
    
    var isMe: isME
    /// iF NIL -> ""
    var content: String
    /// IF NIL -> []
    
    var files: [String]
    var date: Date
    var isFirstDate: Bool
}
