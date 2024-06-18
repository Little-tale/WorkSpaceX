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
}

@Reducer
struct WorkSpaceListCordinator {
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        static let initialState = State(
            identeRoutes: [.root(.rootScreen(WorkSpaceListFeature.State(id: uuid)), embedInNavigationView: true)]
        )
        
        var identeRoutes: IdentifiedArrayOf<Route<WorkSpaceListScreens.State>>
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
                return .send(.router(.routeAction(id: WorkSpaceListCordinator.State.uuid, action: .rootScreen(.currentWorkSpaceIdCatch(id)))))
                
            case .router(.routeAction(id: _, action: .rootScreen(.openSideMenu))) :
                
                return .run { send in
                    await send(.delegate(.openSideMenu))
                }
                
            default:
                break
                
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
    
}


