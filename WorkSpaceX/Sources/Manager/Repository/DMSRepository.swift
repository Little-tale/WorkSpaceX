//
//  DMSRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

struct DMSRepository {
    
    @Dependency(\.dmsMapper) var dmsMapper
    
    func dmRoomListReqeust(_ workSpaceID: String) async throws -> [DMSRoomEntity] {
        let result = try await NetworkManager.shared.requestDto(
            DMSRoomListDTO.self,
            router: DMSRouter.dmRoomListReqeust(workSpaceID),
            errorType: DMSListAPIError.self
        )
        return dmsMapper.toEntity(result)
    }
    
    func dmsRealmToEntity(_ models: [DMSRoomRealmModel]) -> [DMSRoomEntity] {
        var results = [DMSRoomEntity] ()
        for model in models {
            results.append(dmsRealmToEntity(model))
        }
        return results
    }
    
    func dmsRealmToEntity(_ model: DMSRoomRealmModel) -> DMSRoomEntity {
        
        let member = WorkSpaceMembersEntity(
            userID: model.userID,
            email: model.email,
            nickname: model.nickName,
            profileImage: model.profileImage
        )
        
        return DMSRoomEntity(
            roomId: model.roomId,
            createdAt: model.createdAt,
            user: member
        )
    }
}

extension DMSRepository: DependencyKey {
    
    static var liveValue: Self = Self ()
    
}

extension DependencyValues {
    var dmsRepository: DMSRepository {
        get { self[DMSRepository.self] }
        set { self[DMSRepository.self] = newValue }
    }
}
