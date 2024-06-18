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
/// ERROR
//extension WorkSpaceDomainMapper {
//    
////    func regworkSpaceErrorMapper(error: Error) -> WorkSpaceDomainError {
////        guard let error = error as? APIError else {
////            return .commonError(.fail)
////        }
////        switch error {
////        case .httpError(let string):
////            print(string)
////            return .commonError(.fail)
////        case .commonError(let commonError):
////            if  WorkSpaceDomainError.makeWoekSpaceError(commonError.errorCode).thisError {
////                return .makeWoekSpaceError(commonError.errorCode)
////            }
////            
////            return .commonError(commonError)
////        case .customError(let string):
////            return .makeWoekSpaceError(string)
////        case .unknownError:
////            return .commonError(.fail)
////        }
////    }
//    
//}
