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
    
    func dmsRoomRequest(_ workSpaceID: String, otherUserID: String ) async throws -> DMSRoomEntity {
        let reqeust = dmsMapper.toDTOReqeust(otherUserID)
        
        let result = try await NetworkManager.shared.requestDto(
            DMSRoomDTO.self,
            router: DMSRouter.dmRoomReqeust(
                workSpaceID,
                requestDTO: reqeust
            ), errorType: DMSRoomAPIError.self)
        let mapping = dmsMapper.toEntity(result)
        
        return mapping
    }
    
    func dmRoomUnreadReqeust(_ workSpaceId: String, roomID: String, date: String?) async throws -> DMSUnReadEntity {
        
        let result = try await NetworkManager.shared.requestDto(
            DMSRoomUnReadDTO.self,
            router: DMSRouter.dmRoomUnReadReqeust(
                workSpaceId,
                roomID: roomID,
                date: date
            ), errorType: DMSListAPIError.self)
        
        return dmsMapper.toEntity(result)
    }
    
    func dmsChatListRqeust(_ roomID: String, workSpaceId: String, cursurDate: String?) async throws -> [DMSChatEntity]  {
        
        let result = try await NetworkManager.shared.requestDto(
            DMSChatListDTO.self,
            router: DMSRouter.dmRoomChatsReqeust(
            workSpaceId,
            roomID: roomID,
            date: cursurDate
            ), errorType: DMSListAPIError.self)
        
        let mapping = dmsMapper.toEntity(result)
        
        return mapping
    }
    
    @discardableResult
    func sendChatReqeust(_ workSpaceID: String, roomID: String, reqeust: ChatMultipart) async throws ->  DMSChatEntity {
        
        let result = try await NetworkManager.shared.requestDto(
            DMSChatDTO.self,
            router: DMSRouter.sendDmMessage(
                workSpaceID,
                roomID: roomID,
                reqeust: reqeust,
                boundary: MultipartFormData.randomBoundary()
            ),
            errorType: DMSRoomAPIError.self
        )
        let mapping = dmsMapper.toEntity(result)
        return mapping
    }
    
}

extension DMSRepository {
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
