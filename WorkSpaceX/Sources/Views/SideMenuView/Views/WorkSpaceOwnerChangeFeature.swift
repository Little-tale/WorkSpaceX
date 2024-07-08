//
//  WorkSpaceOwnerChangeFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceOwnerChangeFeature {
    
    @ObservableState
    struct State: Equatable {
        let workSpaceID: String
        
        var currentWorkSpaceMemeber: [WorkSpaceMembersEntity] = []
        
        var selectedModel: WorkSpaceMembersEntity? = nil
        
        var changing: Bool = false
        
        var errorMessage: String? = nil
    }
    
    @Dependency(\.workspaceDomainRepository) var workRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.dismiss) var dismiss
    
    enum Action {
        
        case onAppear
        
        case delegate(Delegate)
        case parentAction(ParentAction)
        
        case currentWorkSpaceMembers([WorkSpaceMembersEntity])
        
        case selectedMember(WorkSpaceMembersEntity)
        case selectedModel(WorkSpaceMembersEntity?)
        case confirmMember(WorkSpaceMembersEntity)
        case changing(Bool)
        
        case errorMessage(String?)
        
        case success
        
        enum Delegate {
            case successForChanged
        }
        enum ParentAction {
            
        }
    }
    
    
    
    var body: some ReducerOf<Self> {
        
        Reduce{ state, action in
            switch action {
            case .onAppear:
                let id = state.workSpaceID
                return .run { send in
                    let result = try await workRepo.workSpaceMemberUpdate(id)
                    await send(.currentWorkSpaceMembers(result))
                }
                
            case let .currentWorkSpaceMembers(models):
                var models = models
                if let userID = UserDefaultsManager.userID {
                    models = models.filter { $0.userID != userID }
                }
                state.currentWorkSpaceMemeber = models
                
            case let .selectedMember(model):
                return .run { send in
                    await send(.selectedModel(model))
                }
                
            case let .selectedModel(model):
                state.selectedModel = model
                
            case let .confirmMember(model):
                let workSpace = state.workSpaceID
                let ownerID = model.userID
                return .run { send in
                    await send(.changing(true))
                    let result = try await workRepo.workSpaceOWnerChange(
                        workSpaceID: workSpace,
                        ownerID: ownerID
                    )
                    try await realmRepo.upsertWorkSpace(response: result)
                    await send(.selectedModel(nil))
                    await send(.success)
                } catch: { error, send in
                    if let error = error as? ChannelOwnerChangedAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error)}
                    } else { print(error) }
                }
                
            case let .changing(bool):
                state.changing = bool
                
            case .success:
                return .run { send in
                    await send(.delegate(.successForChanged))
                    await self.dismiss()
                }
                
            default:
                break
            }
            
            return .none
        }
    }
}
