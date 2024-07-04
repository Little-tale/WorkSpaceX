//
//  UserEditDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import Foundation

struct UserEditDTO: DTO {
    let user_id: String
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let provider: String?
    let createdAt: String
}
