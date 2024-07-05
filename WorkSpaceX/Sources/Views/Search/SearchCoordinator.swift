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
}


@Reducer
struct SearchCoordinator {
    
    @ObservableState
    struct State: Equatable {
        
        static let uuid = UUID()
        
        static let homeID = UUID()
        
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
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
}
