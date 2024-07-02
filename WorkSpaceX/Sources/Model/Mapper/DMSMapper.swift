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

extension DMSMapper {
    func toDTOReqeust(_ otherUserID: String) -> DMSRoomRequestDTO {
        return DMSRoomRequestDTO(opponent_id: otherUserID)
    }
}


extension DMSMapper {
    func toEntity(_ dto: DMSRoomUnReadDTO) -> DMSUnReadEntity {
        return DMSUnReadEntity(
            roomId: dto.room_id,
            count: dto.count
        )
    }
    
    func toEntity(_ dtos: DMSChatListDTO) -> [DMSChatEntity] {
        return dtos.chats.map { toEntity($0) }
    }
    
    func toEntity(_ dto: DMSChatDTO) -> DMSChatEntity {
        return DMSChatEntity(
            dmID: dto.dm_id,
            roomID: dto.room_id,
            content: dto.content,
            createdAt: dto.createdAt,
            files: dto.files,
            user: toEntity(dto.user)
        )
    }
    
    func toEntity(_ dto: WorkSpaceAddMemberDTO) -> WorkSpaceMembersEntity {
        return WorkSpaceMembersEntity(
            userID: dto.user_id,
            email: dto.email,
            nickname: dto.nickname,
            profileImage: dto.profileImage
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
