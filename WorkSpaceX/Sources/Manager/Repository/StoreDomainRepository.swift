//
//  StoreDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation
import ComposableArchitecture

protocol StoreRepositoryType {
    func storeList() async throws -> [StoreItemEntity]
}

struct StoreDomainRepository: StoreRepositoryType {
    
    @Dependency(\.storeMapper) var storeMapper
    
    func storeList() async throws -> [StoreItemEntity] {
        let result = try await NetworkManager.shared.requestDto(
            StoreItemListDTO.self,
            router: StoreRouter.storeItemList,
            errorType: StoreListApiError.self
        )
        let mapping = storeMapper.toEntity(result)
        
        return mapping
    }
    
}

extension StoreDomainRepository: DependencyKey {
    static var liveValue: Self = Self()
}

extension DependencyValues {
    var storeRepository: StoreDomainRepository {
        get { self[StoreDomainRepository.self] }
        set { self[StoreDomainRepository.self] = newValue }
    }
}
