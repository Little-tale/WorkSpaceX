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
        case other(String) // 유저 이름
    }
    
    var isMe: isME
    var chatMode: ChatMode
    /// iF NIL -> ""
    var content: String
    /// IF NIL -> []
    var files: [String]
    
}
