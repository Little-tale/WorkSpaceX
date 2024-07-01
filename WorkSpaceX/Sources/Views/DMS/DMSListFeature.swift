//
//  DMSListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMSListFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        var currentWorkSpaceID: String = ""
        var onAppearTrigger: Bool = true
        var navigationImage: String? = nil
        
        var errorMessage: String? = nil
        
        var userList: [WorkSpaceMembersEntity] = []
        
        var viewState: DmViewState = .loading
    }
    enum DmViewState {
        case loading
        case empty
        case members
    }
    
    enum Action {
        case onAppaer
        
        case parentAction(ParentAction)
        case delegate(Delegate)
        
        case workSpaceInfoObserver(workSpaceID: String)
        
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        case requestWorkSpaceMember(WorkSpaceID: String)
        case realmToUpdateMember([WorkSpaceMembersEntity])
        case justReqeustRealmMember(WorkSpaceID: String)
        
        case users([WorkSpaceMembersEntity])
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        enum Delegate {
            case clickedAddMember
        }
        case clickedAddMember
        case errorMessage(String?)
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppaer:
                print(state.currentWorkSpaceID)
                let id = state.currentWorkSpaceID
                let bool = state.onAppearTrigger
                return .run { send in
                    if id != "", bool {
                        await send(.workSpaceInfoObserver(workSpaceID: id))
                    }
                    if id != "" {
                        await send(.requestWorkSpaceMember(WorkSpaceID: id))
                        
                    }
                }
            case let .parentAction(.getWorkSpaceId(id)):
                state.currentWorkSpaceID = id
                
            case let .workSpaceInfoObserver(workSpaceID):
                if state.onAppearTrigger {
                    state.onAppearTrigger = false
                    return .run { @MainActor send in
                        for await currentModel in workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                            print("응답 받음 ")
                            if let currentModel{
                                send(.catchToWorkSpaceRealmModel(currentModel))
                            }
                        }
                    }
                }
            case let .requestWorkSpaceMember(id):
                return .run { send in
                    let result = try await workSpaceRepo.workSpaceMemberUpdate(id)
                    
                    await send(.realmToUpdateMember(result))
                    
                    await send(.justReqeustRealmMember(WorkSpaceID: id))
                } catch: { error, send in
                    if let error = error as? WorkSpaceMembersAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .realmToUpdateMember(members):
                if state.currentWorkSpaceID != "" {
                    let id = state.currentWorkSpaceID
                    return .run { @MainActor send in
                        try await realmRepo.upsertWorkSpaceInMembers(responses: members, workSpaceID: id)
                    }
                }
                
            case let .justReqeustRealmMember(workSpaceID):
                
                return .run { send in
                    let result = try await realmRepo.findMembers(workSpaceID: workSpaceID)
                    let member = await realmRepo.userToMember(result)
                    await send(.users(member))
                } catch: { error, send in
                    print(error)
                }
                
            case let .users(member):
                if let user = UserDefaultsManager.userID {
                    let models = member.filter({ $0.userID != user })
                    state.userList = models
                    if models.count == 0 {
                        state.viewState = .empty
                    } else {
                        state.viewState = .members
                    }
                } else {
                    state.userList = member
                }
                
                
            case let .catchToWorkSpaceRealmModel(model):
                state.navigationImage = model.coverImage
            case .clickedAddMember:
                return .run { send in
                    await send(.delegate(.clickedAddMember))
                }
                
            default:
                break
            }
            return .none
        }
    }
    
}
