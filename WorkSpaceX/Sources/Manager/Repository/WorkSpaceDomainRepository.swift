//
//  WorkSpaceDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation
import ComposableArchitecture

struct WorkSpaceDomainRepository {
    var regWorkSpaceReqeust: (NewWorkSpaceRequest) async throws -> WorkSpaceEntity
    var findMyWordSpace: () async throws -> [WorkSpaceEntity]
    
    var workSpaceRemove: (_ workSpaceID: String) async throws -> Void
    var modifySpaceReqeust: (_ model: EditWorkSpaceReqeust,_ id: String) async throws -> WorkSpaceEntity
    
    var findWorkSpaceChnnel: (_ workSpaceID: String) async throws -> [ChanelEntity]
    
    var regWorkSpaceChannel: (NewWorkSpaceRequest, _ workSpaceID: String) async throws -> ChanelEntity
    
    var addWorkSpaceMember: (_ workSpace: String, _ email: String) async throws -> WorkSpaceMembersEntity
    
    var workSpaceMemberUpdate: (_ workSpace: String) async throws -> [WorkSpaceMembersEntity]
    
    var workSpaceSearchingToChannel: (_ workSpaceID: String) async throws -> [ChanelEntity]
    
    var workSpaceChattingList: (_ workSpaceID: String, _ channelId: String,_ ifDate: Date?) async throws -> [WorkSpaceChatEntity]
    
    var channelInfoRequest: (_ workSpaceID: String, _ channelID: String) async throws -> ChanelEntity
    
    var sendChatting: (_ workSpaceID: String, _ ChannelID: String,_ model: ChatMultipart) async throws -> WorkSpaceChatEntity
    
    var channelSocketReqeust: (_ channelID: String) -> AsyncStream<Result<WorkSpaceChatEntity,ChatSocketManagerError>>
    
    var exitChannel: (_ workSpaceID: String,_ channelID: String) async throws -> [ChanelEntity]
    
    var editToChannel: (_ workSpaceID: String,_ channelID: String, _ reqesut: ModifyWorkSpaceDTORequest) async throws -> ChanelEntity
    
    var channelOWnerChanged: (_ workSpaceID: String, _ ChannelID: String, _ changedID: String) async throws -> ChanelEntity
    
    var channelDeleteReqeust: (_ workSpaceID: String, _ channelID: String) async throws -> Void
    
    var workSpaceKeywordSearching: (_ workSpaceID: String, _ Keyword: String) async throws -> (Channel: [WorkSpaceChannelEntity], Member: [WorkSpaceMembersEntity])
}

extension WorkSpaceDomainRepository: DependencyKey {
    
    static let workSpaceMapper = WorkSpaceDomainMapper()
    
    static var liveValue: Self = Self (
        regWorkSpaceReqeust: { model in
            let reqeustDTO = workSpaceMapper.workSpaceReqeustDTO(model: model)
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceDTO.self, router: WorkSpaceRouter.makeWorkSpace(reqeustDTO, randomBoundary: MultipartFormData.randomBoundary()), errorType: MakeWorkSpaceAPIError.self)
            
            UserDefaultsManager.workSpaceSelectedID = result.workspace_id
            
            let entity = workSpaceMapper.toWorkSpaceModel(
                model: result
            )
            return entity
            
        }, findMyWordSpace: {
            let result = try await NetworkManager.shared.requestDto(WorkSpaceaListDTO.self, router: WorkSpaceRouter.meWorkSpace, errorType: WorkSpaceMeError.self)
                
                let mapping = workSpaceMapper.toWorkSpaceListModel(result)
                
                
                return mapping
        }, workSpaceRemove: { workSpaceID in
            let _ = try await NetworkManager.shared.request(WorkSpaceRouter.removeWorkSpace(workSpaceId: workSpaceID), errorType: WorkSpaceRemoveAPIError.self)
            return
        }, modifySpaceReqeust: { model, id in
            
            let reqeustMapping = workSpaceMapper.workSpaceReqeustDTO(model: model)
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceDTO.self, router: WorkSpaceRouter.modifyWorkSpace(reqeustMapping, randomBoundary: MultipartFormData.randomBoundary(), workSpaceID: id), errorType: WorkSpaceEditAPIError.self)
            
            let mapping = workSpaceMapper.toWorkSpaceModel(model: result)
            
            return mapping
        }, findWorkSpaceChnnel: { workSpaceID in
            
           let result = try await NetworkManager.shared.requestDto(WorkSpaceChannelListDTO.self, router: WorkSpaceRouter.findWorkSpaceChannels(workSpaceID: workSpaceID), errorType: WorkSpaceMyChannelError.self)
            
            return workSpaceMapper.workSpaceChannelListDTOToChannels(dto: result)
        }, regWorkSpaceChannel: { request, workSpaceID in
            
            let requestDTO = workSpaceMapper.workSpaceReqeustDTO(model: request)
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceChanelsDTO.self, router: WorkSpaceRouter.createChannel(requestDTO, workSpaceID: workSpaceID, boundary: MultipartFormData.randomBoundary()), errorType: WorkSpaceMakeChannelAPIError.self)
            
            let mapping = workSpaceMapper.workSpaceChanelsDTOToChannel(dto: result)
            
            return mapping
        }, addWorkSpaceMember: { workSpaceID, email in
            
            let reqeustModel = workSpaceMapper.toWorkSpaceAddMemberRequestDTO(email)
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceAddMemberDTO.self, router: WorkSpaceRouter.workSpaceAddMember(workSpaceId: workSpaceID, request: reqeustModel), errorType: WorkSpaceAddMemberAPIError.self)
            
            let mapping = workSpaceMapper.workSpaceAddMemberDTOToEntity(dto: result)
            return mapping
        }, workSpaceMemberUpdate: { workSpaceID in
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceMembersDTO.self, router: WorkSpaceRouter.workSpaceMembersReqeust(workSpaceId: workSpaceID), errorType: WorkSpaceMembersAPIError.self)
            
            let members = result.members
            
            let mapping = workSpaceMapper.workSpaceMembersDTOToEntity(dtos: members)
            
            return mapping
        }, workSpaceSearchingToChannel: { workSpaceID in
            
           let result = try await NetworkManager.shared.requestDto(
                WorkSpaceChannelListDTO.self,
                router: WorkSpaceRouter.channelListSearching(
                    workSpaceId: workSpaceID
                ), errorType: WorkSpaceChannelListAPIError.self
            )
            
            let mapping = workSpaceMapper.workSpaceChannelListDTOToChannels(dto: result)
            
            return mapping
        }, workSpaceChattingList: { workSpaceID, channelID, ifDate in
            var requestDate : String?
            if let ifDate {
                requestDate = DateManager.shared.toDateISO(ifDate)
            }
            print("요청중인 \(workSpaceID) channel: \(channelID)")
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceChatListDTO.self, router: WorkSpaceRouter.workSpaceChatRequest(workSpaceId: workSpaceID, channelID: channelID, ifDate: requestDate), errorType: WorkSpaceChannelListAPIError.self)
            
            return workSpaceMapper.workSpaceChatDtoToEntity(dtos: result.workSpaceChats)
            
        }, channelInfoRequest: { workSapceID, channelID in
            
            let result = try await NetworkManager.shared.requestDto(WorkSpaceChanelInfoDTO.self, router: WorkSpaceRouter.channelInfoReqesut(workSpaceId: workSapceID, channelID: channelID), errorType: WorkSpaceChannelListAPIError.self)
            
            let mapping = workSpaceMapper.workSpaceChanelInfoDTOToEntity(dto: result)
            
            return mapping
        }, sendChatting: { workSpaceID, channelID, model in
            let result = try await NetworkManager.shared.requestDto(
                WorkSpaceChatDTO.self,
                router: WorkSpaceRouter.sendChat(
                    workSpaceID: workSpaceID,
                    channelID,
                    model,
                    boundary: MultipartFormData.randomBoundary()
                ),
                errorType: WorkSpaceChatSendAPIError.self
            )
            print("쳇 결과 : ",result.files)
            return workSpaceMapper.workSpaceChatDtoToEntity(dto: result)
        }, channelSocketReqeust: { channelID in
            return AsyncStream { contin in
                Task {
                    let stream = WSXSocketManager.shared.connect(
                        to: .channelChat(channelID: channelID),
                        type: WorkSpaceChatDTO.self
                    )
                    print("중간 소켓 관찰 시작")
                    for await result in stream {
                        switch result {
                        case .success(let success):
                            print("중간 소켓 형변환")
                            let model = workSpaceMapper.workSpaceChatDtoToEntity(dto: success)
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
        }, exitChannel: { workSpaceID, channelID in
            
            let result = try await NetworkManager.shared.requestDto(
                WorkSpaceChannelListDTO.self,
                router: WorkSpaceRouter.exitChannel(
                workSpaceID: workSpaceID, channelID
                ), errorType: WorkSpaceExitChannelAPIError.self)
            
            let mapping = workSpaceMapper.workSpaceChannelListDTOToChannels(dto: result)
            
            return mapping
        }, editToChannel: { wornSpaceId, ChannelID, request in
            
            let result = try await NetworkManager.shared.requestDto(
                WorkSpaceChanelsDTO.self,
                router: WorkSpaceRouter.editToChannel(
                    workSpaceID: wornSpaceId,
                    ChannelID, multi: request,
                    randomBoundary: MultipartFormData.randomBoundary()
                ), errorType: ChannelEditAPIError.self)
            
            let mapping = workSpaceMapper.workSpaceChanelsDTOToChannel(
                dto: result
            )
            
            return mapping
            
        }, channelOWnerChanged: { workSpaceID, channelID, changedID in
            
            let reqeust = ChannelOwnerRequestDTO(owner_id: changedID)
            
            let result = try await NetworkManager.shared.requestDto(
                WorkSpaceChanelsDTO.self,
                router: WorkSpaceRouter.channelOwnerChanged(
                    workSpaceId: workSpaceID,
                    ChannelID: channelID,
                    request: reqeust
                ),
                errorType: ChannelOwnerChangedAPIError.self
            )
            let mapping = workSpaceMapper.workSpaceChanelsDTOToChannel(dto: result)
            
            return mapping
        }, channelDeleteReqeust: { workSpaceID, channelID in
            let result = try await NetworkManager.shared.request(
                WorkSpaceRouter.channelDelete(
                workSpaceID: workSpaceID,
                channelID: channelID),
                errorType: ChannelDeleteAPIError.self
            )
            return 
        }, workSpaceKeywordSearching: { workSpaceID, keyword in
            let result = try await NetworkManager.shared.requestDto(
                SearchResultDTO.self,
                router: WorkSpaceRouter.searchKeywork(
                    workSpaceID: workSpaceID,
                    keyword: keyword
                ),
                errorType: WorkSpaceSearchToListAPIError.self
            )
            let mapping = workSpaceMapper.toEntity(result)
            
            return mapping
        }
    )
    
    func reqeustUserInfo(userID: String) async throws -> WorkSpaceMembersEntity {

        let result = try await NetworkManager.shared.requestDto(
            WorkSpaceAddMemberDTO.self,
            router: WorkSpaceRouter.reqeustUser(
                userID: userID
            ),
            errorType: UserInfoReqeustAPIError.self
        )
        let mapping = WorkSpaceDomainRepository.workSpaceMapper.workSpaceAddMemberDTOToEntity(
            dto: result
        )
        return mapping
    }
    
    func toChannelSection(models: [WorkSpaceChannelRealmModel]) -> WorkSpaceChannelsEntity {
        var results: [WorkSpaceChannelEntity] = []
        for model in models {
            results.append(WorkSpaceChannelEntity(
                channelID: model.channelID,
                name: model.name,
                introduce: model.introduce,
                ownerID: model.ownerID,
                didNotReadCount: model.didNotReadCount
            )
            )
        }
        
        return WorkSpaceChannelsEntity(items: results)
    }
    
}

extension DependencyValues {
    var workspaceDomainRepository: WorkSpaceDomainRepository {
        get { self[WorkSpaceDomainRepository.self] }
        set { self[WorkSpaceDomainRepository.self] = newValue }
    }
}
