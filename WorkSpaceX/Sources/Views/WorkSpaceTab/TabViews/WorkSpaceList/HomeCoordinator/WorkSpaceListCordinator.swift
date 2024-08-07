//
//  WorkSpaceListCordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
// selectedProfileImageView
@Reducer(state: .equatable)
enum WorkSpaceListScreens {
    case rootScreen(WorkSpaceListFeature)
    // Middel
    case workSpaceChannelListView(WorkSpaceChannelListFeature)
    case chattingView(WorkSpaceChannelChattingFeature)
    case dmChat(DMSChatFeature)
    case channelEdit(ChannelEditFeature)
    case ChannelOwnerChange(ChannelOwnerChangeFeature)
    // Profile
    case profileInfo(ProfileInfoFeature)
    case profileEdit(ProfileInfoEditFeature)
    // setting
    case chatChannelSettingView(ChatChannelSettingFeature)
    // PageSheet
    case channelAdd(WorkSpaceChannelAddFeature)
    case memberAdd(AddMemberFeature)
    // 결제
    case storeListView(StoreListFeature)
    
}

@Reducer
struct WorkSpaceListCordinator {
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        
        let sheetID = UUID()
        
        let ChannelListID = UUID()
        
        let channelEditID = UUID()
        
        let profileView = UUID()
        
        let storeView = UUID()
        
        static let initialState = State(
            identeRoutes: [.root(.rootScreen(WorkSpaceListFeature.State(id: uuid)), embedInNavigationView: true)]
        )
        
        var identeRoutes: IdentifiedArrayOf<Route<WorkSpaceListScreens.State>>
        
        var currentWorkSpaceId: String?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<WorkSpaceListScreens>)
        case sendToRootWorkSpaceID(String)
        
        case delegate(Delegate)
        
        enum Delegate {
            case openSideMenu
            case moveToDirect(workSpaceID: String)
            case moveToOnBoardingView
        }
    }
    //currentWorkSpaceIdCatch
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case let .sendToRootWorkSpaceID(id):
                state.currentWorkSpaceId = id
                let uuid = WorkSpaceListCordinator.State.uuid
                return .run { send in
                   await send(.router(.routeAction(id: uuid, action: .rootScreen(.currentWorkSpaceIdCatch(id)))))
                }
                
            case .router(.routeAction(id: _, action: .rootScreen(.openSideMenu))) :
                return .run { send in
                    await send(.delegate(.openSideMenu))
                }
                
            case .router(.routeAction(id: _, action: .rootScreen(.chnnelAddClicked))) :
                
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.presentSheet(.channelAdd(WorkSpaceChannelAddFeature.State(id: state.sheetID, workSpaceId: id)), embedInNavigationView: true)
                }
                
                
            case .router(.routeAction(id: _, action: .rootScreen(.channelSerching))):
                let channelId = state.ChannelListID
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.push(.workSpaceChannelListView(WorkSpaceChannelListFeature
                        .State(
                            id: channelId,
                            workSpaceID: id
                        )))
                }
                // 프로필
            case .router(.routeAction(id: _, action: .rootScreen(.selectedProfileImageView))):
                let uuid = state.profileView
                if let id = UserDefaultsManager.userID {
                    state.identeRoutes.push(
                        .profileInfo(
                            ProfileInfoFeature.State(
                                id: uuid,
                                userType: .me(userID: id),
                                tabBarHidden: true
                            )
                        )
                    )
                }
                // 닉네임 수정으로 전환
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToNickNameChange(let model))))):
                state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                    editType: .nickName,
                    model: model
                )))
                
                
                /// 연락처 수정으로 전환
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToContactChange(let model))))):
                state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                    editType: .contact,
                    model: model
                )))
                // 수정 완료 될시 뒤로가기 연결
            case .router(.routeAction(id: _, action: .profileEdit(.delegate(.regSuccess)))):
                state.identeRoutes.pop()
                
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToOnBoardingView)))):
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
                
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToCoinShop(let coin))))):
                let uuid = state.storeView
                
                state.identeRoutes.push(.storeListView(StoreListFeature.State(
                    id: uuid,
                    currentCoinCount: coin)
                ))
                
                // 채널 탐색
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.dismissTapped))):
                state.identeRoutes.pop()
                
                // 채팅 이동
            case .router(.routeAction(id: _, action: .rootScreen(.parentToAction(.selectedChannel(let workSpaceID, let channel))))):
                if let userId = UserDefaultsManager.userID {
                    state.identeRoutes.push(.chattingView(WorkSpaceChannelChattingFeature.State(
                        channelID: channel.channelID,
                        workSpaceID: workSpaceID,
                        userID: userId,
                        navigationTitle: channel.name))
                    )
                }
                
            case let .router(.routeAction(id: _, action: .rootScreen(.selectedRoom(model)))):
                let model = model
                
                if let userid = UserDefaultsManager.userID,
                   let workSpaceID = state.currentWorkSpaceId {
                    state.identeRoutes.push(.dmChat(DMSChatFeature.State(
                        workSpaceID: workSpaceID,
                        userID: userid,
                        otherUserID: model.user.userID
                    )))
                }
                
                //otherUserID
            case .router(.routeAction(id: _, action: .dmChat(.delegate(.popClicked(let roomID))))):
                WorkSpaceReader.shared.observeDMSStop(roomID)
                WSXSocketManager.shared.stopAndRemoveSocket()
                // 소켓 연결시 해제 해주어야 함.
                state.identeRoutes.pop()
                
            case .router(.routeAction(id: _, action: .dmChat(.delegate(.otherUserProfile(userID: let userID))))):
                let uuid = state.profileView
                
                state.identeRoutes.push(
                    .profileInfo(ProfileInfoFeature.State(
                        id: uuid,
                        userType: .other(userID: userID),
                        tabBarHidden: true
                    ))
                )
                
            case .router(.routeAction(id: _, action: .chattingView(.delegate(.otehrUserProfile(userID: let id))))):
                
                let uuid = state.profileView
                
                state.identeRoutes.push(
                    .profileInfo(ProfileInfoFeature.State(
                        id: uuid,
                        userType: .other(userID: id),
                        tabBarHidden: true
                    ))
                )
            
                // 채팅 넘어감.
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.delegate(.lastConfirm(let model))))) :
                print("전달받음 : ",model)
                
                if let workSpaceID = state.currentWorkSpaceId,
                   let userId = UserDefaultsManager.userID {
                    let chatState = WorkSpaceChannelChattingFeature.State(
                        channelID: model.channelId,
                        workSpaceID: workSpaceID,
                        userID: userId,
                        navigationTitle: model.name
                    )
                    
                    state.identeRoutes.push(.chattingView(chatState))
                }
                // 이미 해당 유저일때 바로 채팅 넘김
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.delegate(.alreadyToConfirm(let model))))):
                if let workSpaceID = state.currentWorkSpaceId,
                   let userId = UserDefaultsManager.userID {
                    let chatState = WorkSpaceChannelChattingFeature.State(
                        channelID: model.channelId,
                        workSpaceID: workSpaceID,
                        userID: userId,
                        navigationTitle: model.name
                    )
                    
                    state.identeRoutes.push(.chattingView(chatState))
                }
                
                // 채널 채팅뷰 뒤로가기시.
            case .router(.routeAction(id: _, action: .chattingView(.delegate(.popClicked)))):
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                
                state.identeRoutes.popToCurrentNavigationRoot()
                
                // 쳇 세팅 이동.
            case .router(.routeAction(id: _, action: .chattingView(.delegate(.sendToList(let channel, let isOwner))))):
                if let workSpaceID = state.currentWorkSpaceId {
                    let chatState = ChatChannelSettingFeature.State(
                        id: state.channelEditID,
                        workSpaceID: workSpaceID,
                        channelEntity: channel,
                        isOwner: isOwner
                    )
                    state.identeRoutes.push(.chatChannelSettingView(chatState))
                    print("리스트 뷰로 이동해야합니다!")
                }
                
                
                // 채널 나가기 완료 시
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.exitConfirm)))):
                print("채널 나옴으로 처음으로 돌아갑니다.")
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                
                if state.currentWorkSpaceId != nil {
                    state.identeRoutes.goBackTo(\.rootScreen)
                }
                // 채널 삭제시..parentToAction
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelDeleteConfirm)))):

                WSXSocketManager.shared.stopAndRemoveSocket()
                
                state.identeRoutes.goBackTo(\.rootScreen)
                
                // 채널 편집뷰로 이동
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelEditClicked(let model, let workSpaceId))))):
                
                state.identeRoutes.presentSheet(
                    .channelEdit(
                        ChannelEditFeature.State(
                            channelEntity: model,
                            workSpaceId: workSpaceId
                        )
                    ),
                    embedInNavigationView: true
                )
                
            case .router(.routeAction(id: _, action: .rootScreen(.parentToAction(.moveToDirectedMessage(WorkSpaceID: let workSpaceId))))):

                return .run { send in
                    await send(.delegate(.moveToDirect(workSpaceID: workSpaceId)))
                }
                
            case .router(.routeAction(id: _, action: .channelEdit(.dismissButtonTapped))):
                
                state.identeRoutes.dismiss()
                
            case .router(.routeAction(id: _, action: .channelEdit(.delegate(.successChannel(_))))):
                
                state.identeRoutes.dismiss()
                let id = state.channelEditID
                return .run { send in
                    await send(.router(.routeAction(id: id, action: .chatChannelSettingView(.onAppear))))
                }
                /// 채널 주인 변경 뷰 이동
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelOwnerChangeReqeust(model: let model, workSpaceID: let id))))):
                
                state.identeRoutes.presentSheet(.ChannelOwnerChange(ChannelOwnerChangeFeature.State(
                    workSpaceID: id,
                    channel: model)
                ), embedInNavigationView: true)
                
                // 채널 주인 변경뷰 뒤로 가기 연결
            case .router(.routeAction(id: _, action: .ChannelOwnerChange(.delegate(.backButtonTapped)))):
                
                state.identeRoutes.dismiss()
                
                // 채널 주인 변경후 뒤로가기 연결
            case .router(.routeAction(id: _, action: .ChannelOwnerChange(.delegate(.successChanged)))):
                
                state.identeRoutes.dismiss()
                let id = state.channelEditID
                return .run { send in
                    await send(.router(.routeAction(id: id, action: .chatChannelSettingView(.onAppear))))
                    await send(.router(.routeAction(id: id, action: .chatChannelSettingView(.parentsAction(.successOwnerChange)))))
                }
                
                // 채널추가
            case .router(.routeAction(id: _, action: .channelAdd(.dismissButtonTapped))):
                state.identeRoutes.dismiss()
                
                
            case .router(.routeAction(id: _, action: .channelAdd(.ifNeedSuccessTrigger))) :
                state.identeRoutes.dismiss()
                
                // 팀원 추가 클릭
            case .router(.routeAction(id: _, action: .rootScreen(.addMemberClicked))) :
                
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.presentSheet(.memberAdd(AddMemberFeature.State( currentWorkSpaceID: id)), embedInNavigationView: true)
                }
                
            case .router(.routeAction(id: _, action: .memberAdd(.dismissButtonTapped))):
                state.identeRoutes.dismiss()
                
            case .router(.routeAction(id: _, action: .memberAdd(.alertSuccessTapped))):
                let id = WorkSpaceListCordinator.State.uuid
                state.identeRoutes.dismiss()
                return .run { send in
                    await send(.router(.routeAction(id: id, action: .rootScreen(.parentToAction(.needToMemberUpdate)))))
                }
                
            default:
                break
                
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
    
}


