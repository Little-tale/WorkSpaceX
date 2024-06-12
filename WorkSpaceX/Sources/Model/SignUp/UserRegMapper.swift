//
//  UserRegMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation
import AuthenticationServices

struct UserRegMapper {
    
    func toEntity(_ userDTO: UserDTO) -> UserEntity {
        
        let entity = UserEntity(
            userID: userDTO.userID,
            email: userDTO.email,
            nickname: userDTO.nickname,
            profileImage: userDTO.profileImage,
            phone: userDTO.phone ?? "" ,
            provider: userDTO.provider,
            createdAt: userDTO.createdAt,
            token: toEntity(userDTO.token)
        )
        return entity
    }
    func toEntity(_ token: TokenDTO) -> TokenModel {
        let entity = TokenModel(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken
        )
        return entity
    }
}

extension UserRegMapper {
    
    static func userEmailDTO(email: String) -> UserEmail {
        return UserEmail(email: email)
    }
    
    func userRegDTO(user: UserRegEntityModel) -> UserDTORequest {
        
        var token: String?
        if UserDefaultsManager.deviceToken != "" {
            token = UserDefaultsManager.deviceToken
        }
        
        return UserDTORequest(
            email: user.email,
            password: user.password,
            nickname: user.nickName,
            phone: user.contact,
            deviceToken: token
        )
    }
    
    func kakaoUser(oauthToken: String,
                   deviceToken: String) -> KakaoLoginDTORequest {
        return KakaoLoginDTORequest(
            oauthToken: oauthToken,
            deviceToken: deviceToken
        )
    }
    
    
    func requestLoginDTO(email: String, password: String, deviceToken: String?) -> LoginRequestDTO {
        return LoginRequestDTO(
            email: email,
            password: password,
            deviceToken: deviceToken
        )
    }
    
    
    func mappingASAuthorization(info: ASAuthorization) -> AppleLoginDTORequest? {
        guard let appleInfo = info.credential as? ASAuthorizationAppleIDCredential else  {
            return nil
        }
        
        let name = appleInfo.fullName?.givenName
        
        UserDefaultsManager.appleLoginNickName = name
        
        var token: String?
        if UserDefaultsManager.deviceToken != "" {
            token = UserDefaultsManager.deviceToken
        }
        
        guard let identy = appleInfo.identityToken,
              let tokenResult = String(data: identy, encoding: .utf8) else {
            return nil
        }
        
        print("애플 토큰",tokenResult)
        
        return AppleLoginDTORequest(
            idToken: tokenResult,
            nickname: UserDefaultsManager.appleLoginNickName,
            deviceToken: token
        )
    }
    
   
}
