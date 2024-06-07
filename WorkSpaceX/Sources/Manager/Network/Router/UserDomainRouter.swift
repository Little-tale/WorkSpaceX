//
//  UserDomainRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum UserDomainRouter: Router {
    
    case userEmail(UserEmail)
    case userReg(UserDTORequest)
}
extension UserDomainRouter {
    
    var method: HTTPMethod {
        switch self {
        case .userEmail, .userReg:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .userEmail:
            return APIKey.version + "/users/validation/email"
        case .userReg:
            return APIKey.version + "/users/join"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .userEmail, .userReg:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userEmail, .userReg:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .userEmail(let userEmail):
            return requestToBody(userEmail)
        case .userReg(let userModel):
            return requestToBody(userModel)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .userEmail, .userReg:
            return .json
        }
    }
}
