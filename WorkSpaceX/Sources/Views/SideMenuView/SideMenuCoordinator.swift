//
//  SideMenuCoordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/15/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators


@Reducer
struct SideMenuCoordinator {
    
    @Reducer(state:.equatable)
    enum SideMenuScreen {
        case base(WorkSpaceSideFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        static let selfInit = State(
            routes: [.root(.base(WorkSpaceSideFeature.State()))]
        )
        
        var routes: IdentifiedArrayOf<Route<SideMenuScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SideMenuScreen>)
        
        case backOff
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            
                // 최상위 뷰에게 전달함. 내려달라고.
            case .router(.routeAction(id: _, action: .base(.goBackToRoot))):
                return .run { send in
                    await send(.backOff)
                }
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
