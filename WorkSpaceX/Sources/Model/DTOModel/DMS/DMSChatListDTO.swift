//
//  DMSChatListDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct DMSChatListDTO: DTO {
    let chats: [DMSChatDTO]

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var chats = [DMSChatDTO] ()
        while !container.isAtEnd {
            let chat = try container.decode(DMSChatDTO.self)
            chats.append(chat)
        }
        self.chats = chats
    }
}
