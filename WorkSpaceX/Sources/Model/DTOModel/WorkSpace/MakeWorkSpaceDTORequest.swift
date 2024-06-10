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
    /// base64 binary로 변환하여 넣어주시길 바랍니다.
    let image: String
}
