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
                return .run { send in
                   await send(.router(.routeAction(id: WorkSpaceListCordinator.State.uuid, action: .rootScreen(.currentWorkSpaceIdCatch(id)))))
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
                // 채널 탐색
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.dismissTapped))):
                state.identeRoutes.pop()
    
                // 채팅 넘어감.
            case .router(.routeAction(id: state.ChannelListID, action: .workSpaceChannelListView(.delegate(.lastConfirm(let model))))) :
                print("전달받음 : ",model)
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.push(
                        .chattingView(
                            WorkSpaceChannelChattingFeature.State(
                                channelID: model.channelId,
                                workSpaceID: id,
                                navigationTitle: model.name
                            )
                        )
                    )
                }
            case .router(.routeAction(id: _, action: .chattingView(.popClicked))):
                state.identeRoutes.popToRoot()
                                
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


