//
//  SearchCoordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum SearchListScreens {
    case home(SerachFeature)
    case channelChatView(WorkSpaceChannelChattingFeature)
    case otherProfileView(ProfileInfoFeature)
    case chatChannelSettingView(ChatChannelSettingFeature)
    case chatnnelEdit(ChannelEditFeature)
    case ChannelOwnerChange(ChannelOwnerChangeFeature)
}


@Reducer
struct SearchCoordinator {
    
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        
        static let homeID = UUID()
        
        let channelEditID = UUID()
        
        var currentWorkSpaceID: String?
        
        var identeRoutes: IdentifiedArrayOf<Route<SearchListScreens.State>>
        
        static let initialState = State(identeRoutes: [.root(.home(SerachFeature.State(id: homeID)), embedInNavigationView: true)])
        
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SearchListScreens>)
        
        case parentAction(ParentAction)
        
        enum ParentAction {
            case sendToWorkSpaceID(String)
        }
    }
    
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
                
            case let .parentAction(.sendToWorkSpaceID(workSpaceID)):
                state.currentWorkSpaceID = workSpaceID
                let id = workSpaceID
                let homeID = SearchCoordinator.State.homeID
                return .run { send in
                    await send(.router(.routeAction(id: homeID, action: .home(.parentAction(.sendToWorkSpaceID(id))))))
                }
                // 채널 챗뷰 연결
            case let .router(.routeAction(id: _, action: .home(.delegate(.moveToChannelChatView(model))))):
                let channelID = model.channelID
                
                if let userID = UserDefaultsManager.userID,
                   let workSpaceID = state.currentWorkSpaceID {
                    state.identeRoutes.push(.channelChatView(WorkSpaceChannelChattingFeature.State(
                        channelID: channelID,
                        workSpaceID: workSpaceID,
                        userID: userID,
                        navigationTitle: model.name)
                    ))
                }
                
            case .router(.routeAction(id: _, action: .channelChatView(.popClicked))):
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                
                state.identeRoutes.popToCurrentNavigationRoot()
                
            case let .router(.routeAction(id: _, action: .channelChatView(.sendToList(channel, isOwner)))):
                let setting = state.channelEditID
                if let workSpaceID = state.currentWorkSpaceID {
                    state.identeRoutes.push(.chatChannelSettingView(
                        ChatChannelSettingFeature.State(
                            id: setting,
                            workSpaceID: workSpaceID,
                            channelEntity: channel,
                            isOwner: isOwner
                        )
                    ))
                }
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.exitConfirm)))):
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                
                if let workID =  state.currentWorkSpaceID {
                    state.identeRoutes.goBackTo(\.home)
                }
                
            case .router(.routeAction(id: _, action: .chatChannelSettingView(.delegate(.channelDeleteConfirm)))):
                
                WSXSocketManager.shared.stopAndRemoveSocket()
                state.identeRoutes.goBackTo(\.home)
                
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
                /// 채널 주인뷰 변경
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
                
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
}
