//
//  UserRegMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation
import AuthenticationServices

struct UserRegMapper: Mapper {
    
    func toEntity(_ userDTO: UserDTO) -> UserEntity {

        let entity = UserEntity(
            userID: userDTO.userID,
            email: userDTO.email,
            nickname: userDTO.nickname,
            profileImage: mappingToStringURL(with: userDTO.profileImage),
            phone: userDTO.phone ?? "" ,
            provider: userDTO.provider,
            createdAt: userDTO.createdAt.toDate,
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
    
    func toEntityProfile(_ profileDTO: UserProfileDTO) -> UserInfoEntity {
        let entity = UserInfoEntity(
            userID: profileDTO.userID,
            email: profileDTO.email,
            nickname: profileDTO.nickname,
            profileImage: mappingToStringURL(with: profileDTO.profileImage),
            phone: profileDTO.phone ?? "" ,
            provider: profileDTO.provider,
            createdAt: profileDTO.createdAt.toDate,
            sesacCoin: profileDTO.sesacCoin
        )
        return entity
    }
    
    func toEntity(_ dto: UserEditDTO) -> UserEntity {
        return UserEntity(
            userID: dto.user_id,
            email: dto.email,
            nickname: dto.nickname,
            profileImage: dto.profileImage,
            phone: dto.phone,
            provider: dto.provider,
            createdAt: dto.createdAt.toDate,
            token: nil
        )
    }
    
    func toEntity(_ dto: WorkSpaceAddMemberDTO) -> WorkSpaceMemberEntity {
        
        return WorkSpaceMemberEntity(
            userID: dto.user_id,
            email: dto.email,
            nickName: dto.nickname,
            profileImage: dto.profileImage
        )
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
