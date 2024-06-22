//
//  WorkSpaceChatListDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation

struct WorkSpaceChatListDTO: DTO {
    let workSpaceChats: [WorkSpaceChatDTO]
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var chats = [WorkSpaceChatDTO] ()
        while !container.isAtEnd {
            let chat = try container.decode(WorkSpaceChatDTO.self)
            chats.append(chat)
        }
        self.workSpaceChats = chats
    }
}
