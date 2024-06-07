//
//  UserRegMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

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
        return UserDTORequest(
            email: user.email,
            password: user.password,
            nickname: user.nickName,
            phone: user.contact,
            deviceToken: ""
        )
    }
    
    func kakaoUser(oauthToken: String,
                   deviceToken: String) -> KakaoLoginDTORequest {
        return KakaoLoginDTORequest(
            oauthToken: oauthToken,
            deviceToken: deviceToken
        )
    }
}
