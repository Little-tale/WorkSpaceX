//
//  WorkSpaceListCordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum WorkSpaceListScreens {
    case rootScreen(WorkSpaceListFeature)
    
    // Middel
    case workSpaceChannelListView(WorkSpaceChannelListFeature)
    case chattingView(WorkSpaceChannelChattingFeature)
    case chatnnelEdit(ChannelEditFeature)
    case ChannelOwnerChange(ChannelOwnerChangeFeature)
    
    // setting
    case chatChannelSettingView(ChatChannelSettingFeature)
    
    // PageSheet
    case channelAdd(WorkSpaceChannelAddFeature)
    case memberAdd(AddMemberFeature)
    
}

@Reducer
struct WorkSpaceListCordinator {
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        
        let sheetID = UUID()
        
        let ChannelListID = UUID()
        
        let channelEditID = UUID()
        
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
                let uuid = WorkSpaceListCordinator.State.uuid
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
                
                // 채널 탐색
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.dismissTapped))):
                state.identeRoutes.pop()
                
            case .router(.routeAction(id: _, action: .rootScreen(.parentToAction(.selectedChannel(let workSpaceID, let channel))))):
                if let userId = UserDefaultsManager.userID {
                    state.identeRoutes.push(.chattingView(WorkSpaceChannelChattingFeature.State(
                        channelID: channel.channelID,
                        workSpaceID: workSpaceID,
                        userID: userId,
                        navigationTitle: channel.name))
                    )
                }
            
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
                
                // 채널 채팅뷰 뒤로가기시.
            case .router(.routeAction(id: _, action: .chattingView(.popClicked))):
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                let count = state.identeRoutes.count
                state.identeRoutes.remove(at: count - 1)
                state.identeRoutes.popToCurrentNavigationRoot()
                
                // 쳇 세팅 이동.
            case .router(.routeAction(id: _, action: .chattingView(.sendToList(let channel, let isOwner)))):
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
                if let workID =  state.currentWorkSpaceId {
                    state.identeRoutes.popToCurrentNavigationRoot()
                }
                // 채널 삭제시..
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelDeleteConfirm)))):

                WSXSocketManager.shared.stopAndRemoveSocket()
                
                state.identeRoutes.popToCurrentNavigationRoot()
                
                // 채널 편집뷰로 이동
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelEditClicked(let model, let workSpaceId))))):
                
                state.identeRoutes.presentSheet(
                    .chatnnelEdit(
                        ChannelEditFeature.State(
                            channelEntity: model,
                            workSpaceId: workSpaceId
                        )
                    ),
                    embedInNavigationView: true
                )
                
            case .router(.routeAction(id: _, action: .chatnnelEdit(.dismissButtonTapped))):
                
                state.identeRoutes.dismiss()
                
            case .router(.routeAction(id: _, action: .chatnnelEdit(.delegate(.successChannel(_))))):
                
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
                state.identeRoutes.dismiss()
                
            default:
                break
                
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
    
}


