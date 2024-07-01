//
//  DMSRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

enum DMSRouter: Router {
    
    case dmRoomListReqeust(_ workSpaceID: String)
    
}

extension DMSRouter {
    
    var method: HTTPMethod {
        switch self {
        case .dmRoomListReqeust:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .dmRoomListReqeust(let workSpaceID):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .dmRoomListReqeust:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .dmRoomListReqeust:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .dmRoomListReqeust:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .dmRoomListReqeust:
            return .url
        }
    }
    
}
