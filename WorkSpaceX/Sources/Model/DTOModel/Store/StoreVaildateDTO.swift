//
//  StoreVaildateDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

struct StoreVaildateDTO: DTO {
    let billing_id: String
    let merchant_uid: String
    let buyer_id: String
    let productName: String
    let price: Int
    let sesacCoin: Int
    let paidAt: String
}
