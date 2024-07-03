//
//  UserDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

struct UserDTO: DTO {
    let userID: String
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let provider: String?
    let createdAt: String
    let token: TokenDTO
    
    enum CodingKeys: String, CodingKey {
           case userID = "user_id"
           case email, nickname, profileImage, phone, provider, createdAt, token
       }
}
