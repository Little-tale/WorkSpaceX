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
    
    case editUserInfo(UserInfoEditReqeustDTO)
    case editUserProfileImage(image: Data, boundary: String)
}
extension UserDomainRouter {
    
    var method: HTTPMethod {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister:
            return .post
        case .myProfile:
            return .get
        case .editUserInfo, .editUserProfileImage:
            return .put
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
            
        case .editUserInfo:
            return APIKey.version + "/users/me"
            
        case .editUserProfileImage:
            return APIKey.version + "/users/me/image"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister, .myProfile, .editUserInfo:
            return nil
        case .editUserProfileImage(_, boundary: let boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister, .myProfile, .editUserInfo, .editUserProfileImage:
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
            
        case let .editUserInfo(model):
            return requestToBody(model)
        case .myProfile:
            return nil
        case .editUserProfileImage(image: let image, boundary: let boundary):
            return makeProfileImageMultipartData(
                image,
                boundary: boundary
            )
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .userEmail, .userReg, .kakaoLogin, .emailLogin, .appleLoginRegister, .editUserInfo:
            return .json
        case .myProfile:
            return .url
        case .editUserProfileImage:
            return .multiPart
        }
    }
}
extension UserDomainRouter {
    
    private func makeProfileImageMultipartData(_ image: Data, boundary: String) -> Data {
        
        let multiPart = MultipartFormData()
        
        multiPart.append(
            image,
            withName: "image",
            fileName: "WorkSpace_\(UUID()).jpeg",
            mimeType: MimeType.image.rawValue,
            boundary: boundary
        )
        
        return multiPart.finalize(boundary: boundary)
    }
}
