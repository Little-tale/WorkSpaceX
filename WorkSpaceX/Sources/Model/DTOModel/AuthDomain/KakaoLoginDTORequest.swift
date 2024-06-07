//
//  KakaoLoginDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

struct KakaoLoginDTORequest: DTORequest {
    let oauthToken: String
    let deviceToken: String
}
