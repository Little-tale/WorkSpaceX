//
//  UserProfileDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation

struct UserProfileDTO: DTO {
    let userID, email, nickname: String
    let profileImage: String?
    let phone: String?
    let provider: String?
    let sesacCoin: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, provider, sesacCoin, createdAt
    }
}
