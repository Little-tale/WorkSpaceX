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
        
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.secretKey)_\(Int(Date().timeIntervalSince1970))",
            amount: model.amount
        ).then {
            $0.name = model.item
            $0.buyer_name = "김재형" // 실명이여야 하나 기술적 한계로 저의 이름.
            $0.pay_method = PayMethod.card.rawValue
            $0.app_scheme = "WorkSpaceX"
        }
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
