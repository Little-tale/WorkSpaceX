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
}

extension DMSRouter {
    
    var method: HTTPMethod {
        switch self {
        case .dmRoomListReqeust, .dmRoomUnReadReqeust :
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .dmRoomListReqeust(let workSpaceID):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
        case let .dmRoomUnReadReqeust(workSpaceID, roomID, date):
            return APIKey.version +
            "/workspaces/\(workSpaceID)/dms/\(roomID)/unreads"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .dmRoomListReqeust, .dmRoomUnReadReqeust:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .dmRoomListReqeust:
            return nil
        case let .dmRoomUnReadReqeust(_, _, date):
            if let date {
                return ["after": date]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .dmRoomListReqeust, .dmRoomUnReadReqeust:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .dmRoomListReqeust, .dmRoomUnReadReqeust:
            return .url
        }
    }
    
}
