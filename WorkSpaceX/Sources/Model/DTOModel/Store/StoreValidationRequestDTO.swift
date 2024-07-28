//
//  StoreValidationRequestDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

struct StoreValidationRequestDTO: DTORequest {
    let imp_uid: String
    let merchant_uid: String
}
