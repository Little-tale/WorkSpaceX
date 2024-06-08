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
    case kakaoLogin(KakaoLoginDTORequest)
    case emailLogin(LoginRequestDTO)
    
}
extension UserDomainRouter {
    
    var method: HTTPMethod {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .userEmail:
            return APIKey.version + "/users/validation/email"
        case .userReg:
            return APIKey.version + "/users/join"
        case .kakaoLogin:
            return APIKey.version + "/users/login/kakao"
        case .emailLogin:
            return APIKey.version + "/users/login"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .userEmail(let userEmail):
            return requestToBody(userEmail)
            
        case .userReg(let userModel):
            return requestToBody(userModel)
            
        case let .kakaoLogin(kakao):
            return requestToBody(kakao)
            
        case let .emailLogin(emailLogin):
            return requestToBody(emailLogin)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin:
            return .json
        }
    }
}
