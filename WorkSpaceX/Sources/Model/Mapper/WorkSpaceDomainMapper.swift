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
    
}
