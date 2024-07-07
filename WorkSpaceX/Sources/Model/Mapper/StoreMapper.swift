//
//  StoreMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation
import ComposableArchitecture
import iamport_ios

struct StoreMapper { }

extension StoreMapper {
    
    func toEntity(_ dto: StoreItemListDTO) -> [StoreItemEntity] {
        return dto.itemList.map { toEntity($0) }
    }
    
    func toEntity(_ dto: StoreItemDTO) -> StoreItemEntity {
        return StoreItemEntity(
            item: dto.item,
            amount: dto.amount
        )
    }
    
    func makeIamport(_ model: StoreItemEntity) -> IamportPayment {
        // _\(APIKey.secretKey)
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.secretKey)_\(Int(Date().timeIntervalSince1970))",
            amount: model.amount
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = model.item
            $0.buyer_name = "김재형"
            $0.app_scheme = "WorkSpaceX"
        }
    }
    
    func toEntity(_ dto: StoreVaildateDTO ) -> StoreValidEntity {
        return StoreValidEntity(
            billingID: dto.billing_id,
            merchantUID: dto.merchant_uid,
            buyerID: dto.buyer_id,
            productName: dto.productName,
            price: dto.price,
            sesacCoin: dto.sesacCoin,
            paidAt: dto.paidAt
        )
    }
    
}

extension StoreMapper: DependencyKey {
    static var liveValue: Self = Self()
}

extension DependencyValues {
    var storeMapper: StoreMapper {
        get { self [StoreMapper.self] }
        set { self [StoreMapper.self] = newValue }
    }
}
