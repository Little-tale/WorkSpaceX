//
//  StoreMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation
import ComposableArchitecture

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
