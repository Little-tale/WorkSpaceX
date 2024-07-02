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
        var roomList: [DMSRoomEntity] = []
        
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
        case listDMSInfoObserver(WorkSpaceID: String)
        
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        case requestWorkSpaceMember(WorkSpaceID: String)
        case realmToUpdateMember([WorkSpaceMembersEntity])
        case justReqeustRealmMember(WorkSpaceID: String)
        
        case roomEntityCatch([DMSRoomEntity])
        case users([WorkSpaceMembersEntity])
        case dmsListReqeust(WorkSpaceID: String)
        
        case unReadReqeust([DMSRoomEntity])
        case unReadResults([DMSUnReadEntity])
        
        // 타 사용자 클릭시
        case selectedOtherUser(WorkSpaceMembersEntity)
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        enum Delegate {
            case clickedAddMember
            case moveToDMS(WorkSpaceMembersEntity)
        }
        case clickedAddMember
        case errorMessage(String?)
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.dmsRepository) var dmsRepo
    
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
                        await send(.listDMSInfoObserver(WorkSpaceID: id))
                    }
                    if id != "" {
                        await send(.requestWorkSpaceMember(WorkSpaceID: id))
                        await send(.dmsListReqeust(WorkSpaceID: id))
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
                
            case let .dmsListReqeust(workSpaceID):
                return .run { send in
                    let result = try await dmsRepo.dmRoomListReqeust(workSpaceID)
                    try await realmRepo.upsertDMSRoomEntity(result, workSpaceID: workSpaceID)
                    
                    await send(.roomEntityCatch(result))
                    
                } catch: { error, send in
                    if let error = error as? DMSListAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
            case let .listDMSInfoObserver(workSpaceID):
                if state.onAppearTrigger {
                    return .run { @MainActor send in
                        for await currentModel in workSpaceReader.observerToDMSRoom(workSpaceID: workSpaceID) {
                            let models = dmsRepo.dmsRealmToEntity(currentModel)
                            send(.roomEntityCatch(models))
                        }
                    }
                }
                
            case let .roomEntityCatch(models):
                state.roomList = models
                return .run { send in
                    await send(.unReadReqeust(models))
                }
                
            case let .unReadReqeust(models):
                let id = state.currentWorkSpaceID
                guard id != "" else { break }
                
                return .run { send in
                    do {
                        let results = try await withThrowingTaskGroup(of: DMSUnReadEntity.self) { group in
                            for model in models {
                                group.addTask {
                                    try await dmsRepo.dmRoomUnreadReqeust(
                                        id,
                                        roomID: model.roomId,
                                        date: nil
                                    )
                                }
                            }
                    
                            var results: [DMSUnReadEntity] = []
                            for try await result in group {
                                results.append(result)
                            }

                            return results
                        }
                        
                        await send(.unReadResults(results))
                    } catch {
                        if let error = error as? DMSListAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            case let .selectedOtherUser(model):
                return .run { send in
                    await send(.delegate(.moveToDMS(model)))
                }
                
            default:
                break
            }
            return .none
        }
    }
    
}
