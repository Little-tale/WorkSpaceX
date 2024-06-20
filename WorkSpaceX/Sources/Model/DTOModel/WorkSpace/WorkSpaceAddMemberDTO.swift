//
//  WorkSpaceAddMemberDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import Foundation

struct WorkSpaceAddMemberDTO: DTO {
    let user_id: String
    let email: String
    let nickname: String
    let profileImage: String?
}
