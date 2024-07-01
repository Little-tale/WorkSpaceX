//
//  DMSCoordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import TCACoordinators
import ComposableArchitecture

@Reducer(state: .equatable)
enum DMSListScreens {
    case dmHome(DMSListFeature)
}

@Reducer
struct DMSCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let uuid = UUID()
        var currentWorkSpaceId: String?
        var identeRoutes: IdentifiedArrayOf<Route<DMSListScreens.State>>
        
        static let initialState = State(identeRoutes: [.root(.dmHome(DMSListFeature.State(id: uuid)), embedInNavigationView: true)])
        
    }
    
    
    enum Action {
        case router(IdentifiedRouterActionOf<DMSListScreens>)
        
        case parentAction(ParentAction)
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .parentAction(.getWorkSpaceId(workSpaceID)):
                state.currentWorkSpaceId = workSpaceID
                let id = workSpaceID
                return .run { send in
                    await send(.router(.routeAction(id: DMSCoordinator.State.uuid, action: .dmHome(.parentAction(.getWorkSpaceId(id))))))
                }
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
}
