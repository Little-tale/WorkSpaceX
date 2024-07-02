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
        
//        case unReadReqeust([DMSRoomEntity])
//        case unReadResults([DMSUnReadEntity])
        
        // 타 사용자 클릭시
        case selectedOtherUser(WorkSpaceMembersEntity)
        // 채팅방 클릭시
        case selectedChatRoom(DMSRoomEntity)
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        enum Delegate {
            case clickedAddMember
            case moveToDMS(model: WorkSpaceMembersEntity, workSpaceID: String)
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
                state.roomList = models
                if state.currentWorkSpaceID == "" { break }
                let id = state.currentWorkSpaceID
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        for model in models {
                            group.addTask {
                                do {
                                    // 1. 렘 데이터에서 가장 마지막
                                    let realmDate = try await realmRepo.findDMSChatLastFrontDate(roomID: model.roomId)
                                    
                                    var dateString: String? = nil
                                    
                                    if let realmDate {
                                        dateString = DateManager.shared.toDateISO(realmDate)
                                    }
                                    
                                    let chatList = try await dmsRepo.dmsChatListRqeust(
                                        model.roomId,
                                        workSpaceId: id,
                                        cursurDate: dateString
                                    )
                                    
                                    let unreadCount = try await dmsRepo.dmRoomUnreadReqeust(id, roomID: model.roomId, date: dateString)
                                    
                                    var update = model
                                    
                                    if let lastChat = chatList.last {
                                        update.lastChat = lastChat.content ?? lastChat.files?.first ?? "알수없음"
                                    }
                                    update.unReadCount = unreadCount.count
                                    
                                    try await realmRepo.upsertDMSRoomEntityForRoomList(
                                        update,
                                        workSpaceID: id
                                    )
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
        
                /*
                 // [DMSRoomEntity]
                 let models = models
                 
                 //  렘 데이터에서 사용자가 가장 마지막으로 본 쳇 데이트
                 let realmDate = try await realmRepo.findDMSChatLastDate(
                     roomID: <#T##String#>
                 )
                 // [DMSChatEntity] // 마지막 배열의 채팅 내용 가져와야함.
                 let model = try await dmsRepo.dmsChatListRqeust(
                     <#T##roomID: String##String#>,
                     workSpaceId: <#T##String#>,
                     cursurDate: <#T##String?#>
                 )
                 // 렘 데이터에서 사용자가 가장 마지막으로 본 쳇 데이트
                 //  DMSUnReadEntity // 않읽은 갯수를 반한함.
                 let model2 = try await dmsRepo.dmRoomUnreadReqeust(<#T##workSpaceId: String##String#>, roomID: <#T##String#>, date: <#T##String?#>)
                 
                 try await realmRepo.upsertDMSRoomEntity(<#T##model: DMSRoomEntity##DMSRoomEntity#>, workSpaceID: <#T##String#>)
                 */
                
                
//                    try await realmRepo.upsertDMSRoomEntity(result, workSpaceID: workSpaceID)
                    
//                    await send(.unReadReqeust(models))
               
//            case let .unReadReqeust(models):
//                let id = state.currentWorkSpaceID
//                guard id != "" else { break }
//                
//                return .run { send in
//                    do {
//
//                        
//                        await send(.unReadResults(results))
//                    } catch {
//                        if let error = error as? DMSListAPIError {
//                            if !error.ifDevelopError {
//                                await send(.errorMessage(error.message))
//                            }
//                        } else {
//                            print(error)
//                        }
//                    }
//                }
                /*
                 
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
                 */
//            case let .unReadReqeust(models):
//                let id = state.currentWorkSpaceID
//                guard id != "" else { break }
//                
//                return .run { send in
//                    do {
//                        let results = try await withThrowingTaskGroup(of: DMSUnReadEntity.self) { group in
//                            for model in models {
//                                
//                                group.addTask {
//                                    try await dmsRepo.dmRoomUnreadReqeust(
//                                        id,
//                                        roomID: model.roomId,
//                                        date: nil
//                                    )
//                                }
//                            }
//                    
//                            var results: [DMSUnReadEntity] = []
//                            for try await result in group {
//                                results.append(result)
//                            }
//
//                            return results
//                        }
//                        
//                        await send(.unReadResults(results))
//                    } catch {
//                        if let error = error as? DMSListAPIError {
//                            if !error.ifDevelopError {
//                                await send(.errorMessage(error.message))
//                            }
//                        } else {
//                            print(error)
//                        }
//                    }
//                }
            
            case let .selectedOtherUser(model):
                let id = state.currentWorkSpaceID
                guard id != "" else { break }
                return .run { send in
                    await send(.delegate(.moveToDMS(model: model,workSpaceID: id)))
                }
                
                // 이걸 가장 마지막에 바라보게 해야함....
            case let .listDMSInfoObserver(workSpaceID):
                if state.onAppearTrigger {
                    return .run { @MainActor send in
                        for await currentModel in workSpaceReader.observerToDMSRoom(workSpaceID: workSpaceID) {
                            let models = dmsRepo.dmsRealmToEntity(currentModel)
                            send(.roomEntityCatch(models))
                        }
                    }
                }
                
            default:
                break
            }
            return .none
        }
    }
    
}
