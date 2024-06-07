//
//  UserModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

struct UserEntity: Entity {
    let userID: String
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String
    let provider: String?
    let createdAt: String
    let token: TokenModel
}
