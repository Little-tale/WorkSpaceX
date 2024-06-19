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
    
    
    // PageSheet
    case channelAdd(WorkSpaceChannelAddFeature)
}

@Reducer
struct WorkSpaceListCordinator {
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        
        let sheetID = UUID()
        
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
                return .send(.router(.routeAction(id: WorkSpaceListCordinator.State.uuid, action: .rootScreen(.currentWorkSpaceIdCatch(id)))))
                
            case .router(.routeAction(id: _, action: .rootScreen(.openSideMenu))) :
                return .run { send in
                    await send(.delegate(.openSideMenu))
                }
                
            case .router(.routeAction(id: _, action: .rootScreen(.chnnelAddClicked))) :
                
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.presentSheet(.channelAdd(WorkSpaceChannelAddFeature.State(id: state.sheetID, workSpaceId: id)), embedInNavigationView: true)
                }
                
                
            case .router(.routeAction(id: _, action: .channelAdd(.dismissButtonTapped))):
                
                state.identeRoutes.dismiss()
            case .router(.routeAction(id: _, action: .channelAdd(.ifNeedSuccessTrigger))) :
                state.identeRoutes.dismiss()
                
            default:
                break
                
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
    
}


