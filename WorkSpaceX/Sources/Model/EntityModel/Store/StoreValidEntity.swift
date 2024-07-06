//
//  StoreValidEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation

struct StoreValidEntity: Entity {
    let billingID: String
    let merchantUID: String
    let buyerID: String
    let productName: String
    let price: Int
    let sesacCoin: Int
    let paidAt: String
}
