//
//  AppleLoginDTORequest.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/9/24.
//

import Foundation

struct AppleLoginDTORequest: DTORequest {
    let idToken: String
    let nickname: String?
    let deviceToken: String?
}

