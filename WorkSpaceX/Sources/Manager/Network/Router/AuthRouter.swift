//
//  AuthRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation


enum AuthRouter: Router {
    case refreshToken(access: String, token: String)
}

extension AuthRouter {
    
    var method: HTTPMethod {
        switch self {
        case .refreshToken:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .refreshToken:
            return APIKey.version + "/auth/refresh"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
            
        case let .refreshToken(access, token):
            return [WSXHeader.Key.authorization : access,
                    WSXHeader.Key.refresh: token
            ]
        }
        
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var body: Data? {
       return nil
    }
    
    var encodingType: EncodingType {
        return .url
    }
}
