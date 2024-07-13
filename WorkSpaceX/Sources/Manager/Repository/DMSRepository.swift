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
    
    func dmSocketReqeust(_ roomID: String) -> AsyncStream<Result<DMSChatEntity,ChatSocketManagerError>> {
        return AsyncStream { contin in
            Task {
                let stream = WSXSocketManager.shared.connect(
                    to: .dmsChat(roomID: roomID),
                    type: DMSChatDTO.self
                )
                print("중간 소켓 관찰 시작")
                for await result in stream {
                    switch result {
                    case .success(let success):
                        print("중간 소켓 형변환")
                        let model = dmsMapper.toEntity(success)
                        contin.yield(.success(model))
                    case .failure(let error):
                        print("중간 소켓 에러 발생")
                        contin.yield(.failure(error))
                        contin.finish()
                    }
                }
                print("중간 소켓 관찰 안함.")
                contin.finish()
            }
        }
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
            user: member,
            unReadCount: model.UnReadCount,
            lastChat: model.lastChatText,
            lasstChatDate: model.lastChatDate ?? Date()
        )
    }
    
    
    func toChat(_ model: DMSChatEntity, userID: String, isFirstDate: Bool) -> ChatModeEntity {
        var isMe: isME
        if userID == model.user.userID {
            isMe = .me
        } else {
            isMe = .other(model.user)
        }
        
        return ChatModeEntity(
            chatID: model.dmID,
            isMe: isMe,
            content: model.content ?? "",
            files: model.files ?? [],
            date: model.createdAt.toDate ?? Date(),
            isFirstDate: isFirstDate
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

