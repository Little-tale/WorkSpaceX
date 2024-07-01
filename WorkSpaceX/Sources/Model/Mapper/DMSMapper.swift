//
//  DMSMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

struct DMSMapper: Mapper { }

extension DMSMapper {
    
    func toEntity(_ dtos: DMSRoomListDTO) -> [DMSRoomEntity] {
        return dtos.dmsRooms.map { toEntity($0) }
    }
    
    func toEntity(_ dto: DMSRoomDTO) -> DMSRoomEntity {
        return DMSRoomEntity(
            roomId: dto.room_id,
            createdAt: dto.createdAt,
            user: WorkSpaceMembersEntity(
                userID: dto.user.user_id,
                email: dto.user.email,
                nickname: dto.user.nickname,
                profileImage: dto.user.profileImage
            )
        )
    }
}

extension DMSMapper: DependencyKey {
    static var liveValue: Self = Self()
}

extension DependencyValues {
    var dmsMapper: DMSMapper {
        get { self[DMSMapper.self] }
        set { self[DMSMapper.self] = newValue }
    }
}