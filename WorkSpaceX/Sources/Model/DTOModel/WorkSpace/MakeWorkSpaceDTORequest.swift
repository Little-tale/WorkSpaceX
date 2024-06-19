//
//  makeWorkSpaceDTORequest.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

struct MakeWorkSpaceDTORequest: DTORequest {
    let name: String
    let description: String?
    let image: Data?
}

struct ModifyWorkSpaceDTORequest: DTORequest {
    let name: String
    let description: String?
    let image: Data?
}
