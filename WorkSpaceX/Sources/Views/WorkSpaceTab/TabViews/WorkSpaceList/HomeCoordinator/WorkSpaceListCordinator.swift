//
//  WorkSpaceListCordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer
struct WorkSpaceListCordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(
            routes: [.root(.first(WorkSpaceListFeature.State()), embedInNavigationView: true)]
        )
        
        var routes: IdentifiedArrayOf<Route<WorkSpaceListScreens.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<WorkSpaceListScreens>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            default:
                break
                
               
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
    
}

extension WorkSpaceListScreens.State: Identifiable {
    var id: UUID {
        switch self {
        case let .first(state):
            return state.id
        }
    }
}
