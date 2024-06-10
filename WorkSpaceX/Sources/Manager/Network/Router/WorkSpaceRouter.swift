//
//  WorkSpaceRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

enum WorkSpaceRouter: Router {
    case meWorkSpace
    case makeWorkSpace(MakeWorkSpaceDTORequest)
}
extension WorkSpaceRouter {
    var method: HTTPMethod {
        switch self {
        case .meWorkSpace:
            return .get
        case .makeWorkSpace:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .meWorkSpace:
            return APIKey.version + "workspaces"
        case .makeWorkSpace:
            return APIKey.version + "workspaces"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .meWorkSpace, .makeWorkSpace:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .meWorkSpace, .makeWorkSpace:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .meWorkSpace:
            return nil
        case let .makeWorkSpace(data):
            return requestToBody(data)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .meWorkSpace:
            return .url
        case .makeWorkSpace:
            return .json
        }
    }
    
}
