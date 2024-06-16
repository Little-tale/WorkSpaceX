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
        }
    )
    
}

extension DependencyValues {
    var workspaceDomainRepository: WorkSpaceDomainRepository {
        get { self[WorkSpaceDomainRepository.self] }
        set { self[WorkSpaceDomainRepository.self] = newValue }
    }
}
