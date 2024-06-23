//
//  WorkSpaceDomainMapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

struct WorkSpaceDomainMapper: Mapper {
   
    func toWorkSpaceModel(model: WorkSpaceDTO) -> WorkSpaceEntity {
        
        return WorkSpaceEntity(
            workSpaceID: model.workspace_id,
            name: model.name,
            description: model.description,
            coverImage: mappingToURL(with: model.coverImage),
            ownerID: model.owner_id,
            createdAt: model.createdAt
        )
    }
    
    func toWorkSpaceListModel(_ dtos: WorkSpaceaListDTO ) -> [WorkSpaceEntity] {
        dtos.workSpaces.map { toWorkSpaceModel(model: $0) }
    }
    
}

extension WorkSpaceDomainMapper {
    
    func workSpaceReqeustDTO(
        model: NewWorkSpaceRequest
    ) -> MakeWorkSpaceDTORequest {
        
        return MakeWorkSpaceDTORequest(
            name: model.name,
            description: model.description,
            image: model.image
        )
    }
    
    func workSpaceReqeustDTO(model: EditWorkSpaceReqeust) -> ModifyWorkSpaceDTORequest {
        
        return ModifyWorkSpaceDTORequest(
            name: model.name,
            description: model.description,
            image: model.image
        )
    }
    
}

extension WorkSpaceDomainMapper {
    
    func workSpaceChanelsDTOToChannel(dto: WorkSpaceChanelsDTO) -> ChanelEntity {
        
        return ChanelEntity(
            channelId: dto.channel_id,
            name: dto.name,
            description: dto.description ?? "",
            coverImage: dto.coverImage,
            owner_id: dto.owner_id,
            createdAt: dto.createdAt
        )
    }
    
    func workSpaceChannelListDTOToChannels(dto: WorkSpaceChannelListDTO) -> [ChanelEntity] {
        return dto.chanels.map { workSpaceChanelsDTOToChannel(dto: $0) }
    }
    
    func workSpaceChanelInfoDTOToEntity(dto: WorkSpaceChanelInfoDTO) -> ChanelEntity {
        
        let users = dto.channelMembers.map { workSpaceAddMemberDTOToEntity(dto: $0) }
        
        return ChanelEntity(
            channelId: dto.channel_id,
            name: dto.name,
            description: dto.description ?? "",
            coverImage: dto.coverImage,
            owner_id: dto.owner_id,
            createdAt: dto.createdAt,
            users: users
        )
    }
    
}

extension WorkSpaceDomainMapper {
    
    func toWorkSpaceAddMemberRequestDTO(_ email: String) -> WorkSpaceAddMemberRequestDTO{
        return WorkSpaceAddMemberRequestDTO(email: email)
    }
    
    func workSpaceAddMemberDTOToEntity(dto: WorkSpaceAddMemberDTO) -> WorkSpaceMembersEntity {
        
        return WorkSpaceMembersEntity(
            userID: dto.user_id,
            email: dto.email,
            nickname: dto.nickname,
            profileImage: dto.profileImage
        )
    }
    
    func workSpaceMembersDTOToEntity(dtos: [WorkSpaceAddMemberDTO]) -> [WorkSpaceMembersEntity] {
        return dtos.map { workSpaceAddMemberDTOToEntity(dto: $0)}
    }
}

extension WorkSpaceDomainMapper {
    
    func dateToReqeustChattingDTO(date: Date?) -> ChattingReqeustDTO {
        var reqeust = ""
        if let date {
            reqeust = DateManager.shared.toDateISO(date)
        }
        return ChattingReqeustDTO(cursor_date: reqeust)
    }
    
    func workSpaceChatDtoToEntity(dto: WorkSpaceChatDTO) -> WorkSpaceChatEntity {
        
        return WorkSpaceChatEntity(
            channelId: dto.channel_id,
            channelName: dto.channelName,
            chatId: dto.chat_id,
            content: dto.content,
            createdAt: dto.createdAt,
            files: dto.files,
            user: WorkSpaceMembersEntity(
                userID: dto.user.user_id,
                email: dto.user.email,
                nickname: dto.user.nickname,
                profileImage: dto.user.profileImage
            )
        )
    }
    
    func workSpaceChatDtoToEntity(dtos:  [WorkSpaceChatDTO]) -> [WorkSpaceChatEntity] {
        return dtos.map { workSpaceChatDtoToEntity(dto: $0) }
    }
    
}
