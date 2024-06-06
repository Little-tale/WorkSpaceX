//
//  File.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

struct UserDTORequest: DTORequest {
    let email: String
    let password: String
    let nickname: String
    let phone: String
    let deviceToken: String?
}
