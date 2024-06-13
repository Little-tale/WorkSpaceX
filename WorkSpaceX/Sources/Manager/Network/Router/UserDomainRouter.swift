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
    case appleLoginRegister(AppleLoginDTORequest)
    case myProfile
}
extension UserDomainRouter {
    
    var method: HTTPMethod {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister:
            return .post
        case .myProfile:
            return .get
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
        case .appleLoginRegister:
            return APIKey.version + "/users/login/apple"
        case .myProfile:
            return APIKey.version + "/users/me"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister, .myProfile:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister, .myProfile:
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
            
        case let .appleLoginRegister(appleLogin):
            print(appleLogin)
            return requestToBody(appleLogin)
            
        case .myProfile:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister:
            return .json
        case .myProfile:
            return .url
        }
    }
}
