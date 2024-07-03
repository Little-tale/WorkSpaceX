//
//  UserInfoEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import Foundation

struct UserInfoEntity: Entity {
    let userID: String
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let provider: String?
    let createdAt: Date?
    let sesacCoin: Int
}
