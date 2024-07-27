//
//  WorkSpaceListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@Reducer
struct WorkSpaceListFeature {
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: UUID
        var currentWorkSpaceId: String?
        var workSpaceCoverImage: URL?
        var workSpaceName: String?
        
        var chanelSection = WorkSpaceChannelsEntity(items: [])
        var dmsRoomSection = DMSRoomSectionEntity(items: [])
        
        var alertErrorMessage: String?
        
        @Presents var alert: ConfirmationDialogState<Action.actionSheetAction>?
        var appearTrigger: Bool = true
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.dmsRepository) var dmsRepository
    
    enum isCurrent {
        case empty
        case notEmpty
    }
    
    enum Event: Hashable {
        case Throttle
    }
    
    enum Action {
        case onAppear
        
        case currentWorkSpaceIdCatch(String)
       
        case observerStart(String)
        case firstRealm(String)
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        case updateChannels(WorkSpaceChannelsEntity)
        case updateDMSRooms(DMSRoomSectionEntity)
        
        case workSpaceMembersUpdate(workSpaceID: String)
        // 워크스페이스 채널 네트워크 요청단
        case workSpaceChnnelUpdate(workSpaceID: String)
        // 워크 스페이스 DMRoomList 요청
        case dmRoomListReqeust(wrokSpaceID: String)
        case channelListRequest(wrokSpaceID: String)
        // 팀원 추가
        case addMemberClicked
        // 알렛
        case alertErrorMessage(String?)
        case listDMSInfoObserver(wrokSpaceID: String)
        case channelInfoObserver(workSpaceID: String)
        // 상위뷰 관찰
        case openSideMenu
        case chnnelAddClicked
        case channelSerching
        case selectedProfileImageView
        
        // 채널 생성과 탐색을 분리를 위함.
        case showAlertSheet
        
        // AlertSheet
        case alertSheet(PresentationAction<actionSheetAction>)
        
        // 선택
        case selectedChannel(WorkSpaceChannelEntity)
        case selectedRoom(DMSRoomEntity)
        case selectedNewChannel
        
        // inNeed
        
        @CasePathable
        enum actionSheetAction {
            // 채널 추가
            case chnnelAddClicked
            // 채널 탐색
            case channelSerching
        }
        case parentToAction(ParentToAction)
        
        enum ParentToAction {
            case reload
            case selectedChannel(workSpaceID: String, channel: WorkSpaceChannelEntity)
            case moveToDirectedMessage(WorkSpaceID: String)
            case needToMemberUpdate
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                
                guard let workSpaceID = state.currentWorkSpaceId else {
                    break
                }
                return .run { send in
                    await send(.firstRealm(workSpaceID))
                    
                    await send(.listDMSInfoObserver(wrokSpaceID: workSpaceID))
                    
                    await send(.channelInfoObserver(workSpaceID: workSpaceID))
                    
                    await send(.channelListRequest(wrokSpaceID: workSpaceID))
                    
                    await send(.dmRoomListReqeust(wrokSpaceID: workSpaceID))
                    
                    
                    await send(.workSpaceChnnelUpdate(workSpaceID: workSpaceID))
                    
                    await send(.workSpaceMembersUpdate(workSpaceID: workSpaceID))
                    
                }
                
            case let .currentWorkSpaceIdCatch(workSpaceId):
                print("전달 받음",workSpaceId)
                state.currentWorkSpaceId = workSpaceId
                return .run { send in
                    await send(.onAppear)
                    await send(.observerStart(workSpaceId))
                }
                
            case let .firstRealm(workSpaceId):
                return .run { @MainActor send in
                    let result = try await realmRepo.findModel(workSpaceId, type: WorkSpaceRealmModel.self)
                    
                    print("찾아오기 성공 \(String(describing: result))")
                    
                    if let result {
                        send(.catchToWorkSpaceRealmModel(result))
                    }
                }
            
                
            case let .observerStart(workSpaceID):
                
                return .run { send in
                    for await currentModel in await workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                        print("응답 받음 ")
                        if let currentModel{
                            await send(.catchToWorkSpaceRealmModel(currentModel))
                        }
                    }
                }
                
                
            case let .catchToWorkSpaceRealmModel(model):
                state.currentWorkSpaceId = model.workSpaceID
                let ifImage = model.coverImage
                
                if let ifImage {
                    state.workSpaceCoverImage = URL(string: ifImage)
                }
                state.workSpaceName = model.workSpaceName
                print("응답 받음 \(model.channels.count)")
                return .run { send in
                    let models = await realmRepo.workSpaceToChannel(model)
                    await send(.updateChannels(models))
                }
            case let .updateChannels(models):
                
                state.chanelSection = models
                
            case let .workSpaceMembersUpdate(id):
                return .run { send in
                    let result = try await workSpaceRepo.workSpaceMemberUpdate(id)
                    print("채널: \(result)")
                    try await realmRepo.upsertWorkSpaceInMembers(responses: result, workSpaceID: id)
                } catch: { error, send in
                    if let error = error as? WorkSpaceMembersAPIError {
                        if !error.ifDevelopError {
                            await send(.alertErrorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
                // 채널 업데이트
            case let .workSpaceChnnelUpdate(workSpaceID):
                print("워크스페이스 채널 네트워크 요청 시작")
                return .run { send in
                    let result = try await workSpaceRepo.findWorkSpaceChannel(workSpaceID)
                    print("채널의 결말",result)
                    try await realmRepo.upsertToWorkSpaceChannels(workSpaceId: workSpaceID, channels: result)
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceMyChannelError {
                        if !error.ifDevelopError {
                            await send(.alertErrorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .channelListRequest(workSpaceID):
                return .run { send in
                    let result = try await workSpaceRepo.findWorkSpaceChannel(workSpaceID)
                    await withThrowingTaskGroup(of: Void.self) { group in
                        for model in result {
                            group.addTask {
                                do {
                                    let realmDate = try await realmRepo.findChannelChatLastDate(channelID: model.channelId)
                                    
                                    let chatList = try await workSpaceRepo.workSpaceChattingList(
                                        workSpaceID,
                                        model.channelId,
                                        realmDate
                                    )
                                    
                                    try await realmRepo.upsertToChatInChannel(
                                        models: chatList
                                    )
                                    
                                    try await realmRepo.lastChatUpdateToChannel(channelID: model.channelId)
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        do {
                            try await group.waitForAll()
                        } catch {
                            if let dmsError = error as? WorkSpaceChannelListAPIError {
                                if !dmsError.ifDevelopError {
                                    await send(.alertErrorMessage(dmsError.message))
                                } else {
                                    print(error)
                                }
                            } else {
                                print(error)
                            }
                        }
                    }
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if !error.ifDevelopError {
                            await send(.alertErrorMessage(error.message))
                        }
                    }
                    print(error)
                }
                
                // DMS Room List 요청단
            case let .dmRoomListReqeust(workSpaceID):
               
                return .run { send in
                    let result = try await dmsRepository.dmRoomListReqeust(workSpaceID)
                    try await realmRepo.upsertDMSRoomEntity(result, workSpaceID: workSpaceID, nil)
                    
                    await withThrowingTaskGroup(of: Void.self) { group in
                        for model in result {
                            group.addTask {
                                do {
                                    let realmDate = try await realmRepo.findDMSChatLastDate(roomID: model.roomId)
                                    
                                    var lastChatDateString: String? = nil

                                    if let lastChatDate = realmDate {
                                        lastChatDateString = DateManager.shared.toDateISO(lastChatDate)
                                    }
                                    
                                    let chatList = try await dmsRepository.dmsChatListRqeust(
                                        model.roomId,
                                        workSpaceId: workSpaceID,
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
                                    await send(.alertErrorMessage(dmsError.message))
                                } else {
                                    print(error)
                                }
                            } else {
                                print(error)
                            }
                        }
                    }
                } catch: { error, send in
                    if let error = error as? DMSListAPIError {
                        if !error.ifDevelopError {
                            await send(.alertErrorMessage(error.message))
                        } else {
                            print("설마...?",error)
                        }
                    } else {
                        print("설마...?",error)
                    }
                }
                    .throttle(id: Event.Throttle, for: 0.4, scheduler: RunLoop.main, latest: false)
                
                // 이걸 가장 마지막에 바라보게 해야함....
            case let .listDMSInfoObserver(workSpaceID):
                return .run { @MainActor send in
                    for await currentModel in workSpaceReader.observerToDMSRoom(workSpaceID: workSpaceID) {
                        let models = dmsRepository.dmsRealmToEntity(currentModel)
                        let model = DMSRoomSectionEntity(
                            items: models
                        )

                        send(.updateDMSRooms(model))
                    }
                }
            case let .channelInfoObserver(workSpaceID):
                return .run { @MainActor send in
                    for await currentModel in workSpaceReader.observeChaeelsForWorkSpace(
                        workSpaceId: workSpaceID
                    ) {
                        let models =  workSpaceRepo.toChannelSection(models: currentModel)
                        send(.updateChannels(models))
                    }
                }
                
            case let .updateDMSRooms(model):
                state.dmsRoomSection = model
                // 렘에도 등록해야함
                
                
            case .showAlertSheet:
                state.alert = ConfirmationDialogState(title: {
                    TextState("채널")
                }, actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                            .bold()
                            
                    }
                    ButtonState(action: .chnnelAddClicked) {
                        TextState("채널 생성")
                    }
                    ButtonState(action: .channelSerching) {
                        TextState("채널 탐색")
                    }
                })
                
            case .alertSheet(.presented(.chnnelAddClicked)) :
                state.alert = nil
                return .run { send in
                    await send(.chnnelAddClicked)
                }
            case .alertSheet(.presented(.channelSerching)) :
                state.alert = nil
                return .run { send in
                    await send(.channelSerching)
                }
                
            case .alertSheet(.dismiss):
                state.alert = nil
             
            case .parentToAction(.reload):
                
                return .run { send in
                    await send(.onAppear)
                }
                
            case .selectedChannel(let model):
                if let workSpaceId = state.currentWorkSpaceId {
                    
                    return .run { send in
                        await send(.parentToAction(.selectedChannel(
                            workSpaceID: workSpaceId,
                            channel: model)))
                    }
                }
                /// 상위 코디네이터에서 탭을 전환 -> DM
            case .selectedNewChannel:
                if let workSpaceId = state.currentWorkSpaceId {
                    return .run { send in
                        await send(.parentToAction(.moveToDirectedMessage(WorkSpaceID: workSpaceId)))
                    }
                }
            case .parentToAction(.needToMemberUpdate):
                break
                /*
                 await send(.workSpaceMembersUpdate(workSpaceID: workSpaceID))
                 await send(.observerStart(workSpaceID))
                 */
            
            default :
                break
            }
            return .none
        }
        
    }
}
