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
        
        var stopTrigger: Bool = true
    }
    enum DmViewState {
        case loading
        case empty
        case members
    }
    
    enum CancelID { case timer }
    
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
        case roomEntityShow([DMSRoomEntity])
        case users([WorkSpaceMembersEntity])
        case dmsListReqeust(WorkSpaceID: String)
        
        case infinityStart(WorkSpaceID: String)
        
        // 타 사용자 클릭시
        case selectedOtherUser(WorkSpaceMembersEntity)
        // 본인 프로필 클릭시(네비게이션)
        case selectedMeProfile
        
        // 채팅방 클릭시
        case selectedChatRoom(DMSRoomEntity)
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        enum Delegate {
            case clickedAddMember
            case moveToDMS(model: WorkSpaceMembersEntity, workSpaceID: String)
            case moveToDMSForRoom(model: DMSRoomEntity,workSpaceID: String )
            case moveToProfileView
        }
        case clickedAddMember
        case errorMessage(String?)
        case onDisappear
        case stop
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.dmsRepository) var dmsRepo
    /// Push 기능이  미뤄지어, Polling 방법으로 해결해 보죠.
//    @Dependency(\.continuousClock) var clock
    @Dependency(\.pollingManager) var polling
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppaer:
                print("현재 워크 스페이스 아이디",state.currentWorkSpaceID)
                let id = state.currentWorkSpaceID
                let bool = state.onAppearTrigger
                return .run { send in
                    if id != "", bool {
                        
                    }
                    if id != "" {
                        
                        await send(.requestWorkSpaceMember(WorkSpaceID: id))
                        await send(.infinityStart(WorkSpaceID: id))
                    }
                }
                
            case let .infinityStart(workSpaceID):
                let stop = state.stopTrigger
                return .run { send in
                    
                    await send(.dmsListReqeust(WorkSpaceID: workSpaceID))
                    
                    try await Task.sleep(for: .seconds(2))

                    for await _ in polling.startPolling(every: 2) {
                        await send(.dmsListReqeust(WorkSpaceID: workSpaceID))
                    }
                }
                //                    poling.startPolling(
                //                        every: 2) {
                //                            await send(.dmsListReqeust(WorkSpaceID: workSpaceID))
                //                        }
//                .cancellable(id: CancelID.timer)
                
            case let .parentAction(.getWorkSpaceId(id)):
                state.currentWorkSpaceID = id
                return .run { send in
                    await send(.workSpaceInfoObserver(workSpaceID: id))
                    await send(.listDMSInfoObserver(WorkSpaceID: id))
                }
                
            case let .workSpaceInfoObserver(workSpaceID):
                print("이게 왜...? 에러 \(workSpaceID)")
                return .run { @MainActor send in
                    for await currentModel in workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                        print("응답 받음 ")
                        if let currentModel{
                            send(.catchToWorkSpaceRealmModel(currentModel))
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
                
            case let .roomEntityCatch(models):
                
                if state.currentWorkSpaceID == "" { break }
                let id = state.currentWorkSpaceID
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        for model in models {
                            group.addTask {
                                do {
                                    let realmDate = try await realmRepo.findDMSChatLastDate(roomID: model.roomId)
                                    
                                    var lastChatDateString: String? = nil

                                    if let lastChatDate = realmDate {
                                        lastChatDateString = DateManager.shared.toDateISO(lastChatDate)
                                    }
                                    
                                    let chatList = try await dmsRepo.dmsChatListRqeust(
                                        model.roomId,
                                        workSpaceId: id,
                                        cursurDate: lastChatDateString
                                    )
                                    
                                    try await realmRepo.upsertToDMSChats(models: chatList, roomID: model.roomId)
                                    
                                    try await realmRepo.lastChatUpdatedToDMS(roomID: model.roomId)
                                    
                                } catch {
                                    throw error
                                }
                            }
                        }
                        do {
                            try await group.waitForAll()
                        } catch {
                            if let dmsError = error as? DMSListAPIError {
                                if !dmsError.ifDevelopError {
                                    await send(.errorMessage(dmsError.message))
                                } else {
                                    print(error)
                                }
                            } else {
                                print(error)
                            }
                        }
                    }
                }
            
            case let .selectedOtherUser(model):
                let id = state.currentWorkSpaceID
                guard id != "" else { break }
                return .run { send in
                    await send(.delegate(.moveToDMS(model: model,workSpaceID: id)))
                }
            case let .selectedChatRoom(model):
                let id = state.currentWorkSpaceID
                guard id != "" else { break }
                return .run { send in
                    await send(.delegate(
                        .moveToDMSForRoom(
                            model: model,
                            workSpaceID: id
                        ))
                    )
                }
                
                // 이걸 가장 마지막에 바라보게 해야함....
            case let .listDMSInfoObserver(workSpaceID):
                return .run { @MainActor send in
                    for await currentModel in workSpaceReader.observerToDMSRoom(workSpaceID: workSpaceID) {
                        let models = dmsRepo.dmsRealmToEntity(currentModel)
                        send(.roomEntityShow(models))
                    }
                }
                
            case let .roomEntityShow(models):
                state.roomList = models
                
                /// 네비게이션 자신의 프로필 선택시
            case .selectedMeProfile:
                return .run { send in
                    await send(.delegate(.moveToProfileView))
                }
            case .onDisappear:
                polling.stopPolling()
                return .cancel(id: CancelID.timer)
            default:
                break
            }
            return .none
        }
    }
    
}
