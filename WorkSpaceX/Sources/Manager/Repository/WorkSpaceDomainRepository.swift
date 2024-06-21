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
        }
    )
    
    func workSpaceToChannel(_ workSpace: WorkSpaceRealmModel) -> WorkSpaceChannelsEntity {
        let channel = WorkSpaceChannelsEntity(items: Array(workSpace.channels.sorted(by: \.createdAt)))
        return channel
    }
    
}

extension DependencyValues {
    var workspaceDomainRepository: WorkSpaceDomainRepository {
        get { self[WorkSpaceDomainRepository.self] }
        set { self[WorkSpaceDomainRepository.self] = newValue }
    }
}
