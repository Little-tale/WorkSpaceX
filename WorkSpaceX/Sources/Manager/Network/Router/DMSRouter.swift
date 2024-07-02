//
//  DMSRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

enum DMSRouter: Router {
    
    case dmRoomListReqeust(_ workSpaceID: String)
    
    case dmRoomUnReadReqeust(_ workSpaceID: String, roomID: String, date: String?)
    
    case dmRoomReqeust(_ workSpaceID: String, requestDTO: DMSRoomRequestDTO)
    
    case dmRoomChatsReqeust(_ workSpaceID: String, roomID: String, date: String?)
}

extension DMSRouter {
    
    var method: HTTPMethod {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return .get
        case .dmRoomReqeust:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .dmRoomListReqeust(let workSpaceID):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomUnReadReqeust(workSpaceID, roomID, _):
            return APIKey.version +
            "/workspaces/\(workSpaceID)/dms/\(roomID)/unreads"
            
        case let .dmRoomReqeust(workSpaceID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomChatsReqeust(workSpaceID, roomID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms/\(roomID)/chats"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .dmRoomListReqeust, .dmRoomUnReadReqeust, .dmRoomReqeust, .dmRoomChatsReqeust:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .dmRoomListReqeust, .dmRoomReqeust:
            return nil
        case let .dmRoomUnReadReqeust(_, _, date):
            if let date {
                return ["after": date]
            } else {
                return nil
            }
        case let .dmRoomChatsReqeust(_,_, date):
            if let date {
                return ["cursor_date": date]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return nil
        case let .dmRoomReqeust(_, model):
            return requestToBody(model)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return .url
        case .dmRoomReqeust:
            return .json
        }
    }
    
}
