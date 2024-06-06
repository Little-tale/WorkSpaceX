//
//  UserDomainRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum UserDomainRouter: Router {
    
    case userEmail(UserEmail)
    
}
extension UserDomainRouter {
    
    var method: HTTPMethod {
        switch self {
        case .userEmail:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .userEmail:
            return APIKey.version + "/users/validation/email"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .userEmail:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userEmail:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .userEmail(let userEmail):
            return requestToBody(userEmail)
        }
    }
}
