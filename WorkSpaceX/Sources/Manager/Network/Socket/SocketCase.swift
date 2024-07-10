//
//  SocketCase.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/10/24.
//

import Foundation

enum SocketCase {
    case channelChat(channelID: String)
    case dmsChat(roomID: String)
    var address: String {
        switch self {
        case .channelChat(let channelID):
            return "/ws-channel-\(channelID)"
        case let .dmsChat(roomID):
            return "/ws-dm-\(roomID)"
        }
    }
    
    var eventName: String {
        switch self {
        case .channelChat:
            return "channel"
        case .dmsChat:
            return "dm"
        }
    }
}
