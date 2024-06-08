//
//  LoginRequestDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import Foundation

struct LoginRequestDTO: DTORequest {
    let email: String
    let password: String
    let deviceToken: String?
}
