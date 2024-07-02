//
//  DMSRoomEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

struct DMSRoomEntity: Entity {
    
    let roomId: String
    
    let createdAt: String
    
    let user: WorkSpaceMembersEntity
    
    var unReadCount: Int = 0 
    
    var lastChat: String
    
    var lasstChatDate: Date = Date()
}
