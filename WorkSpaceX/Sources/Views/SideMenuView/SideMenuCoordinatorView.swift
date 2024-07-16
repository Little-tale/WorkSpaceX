//
//  SideMenuCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/15/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators


struct SideMenuCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<SideMenuCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
           
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .base(store):
                    WorkSpaceSideView(store: store)
                }
            }
           
        }
    }
}

extension SideMenuCoordinator.SideMenuScreen.State: Identifiable {
    var id: UUID {
        switch self {
        case let .base(state):
            return state.id
        }
    }
}
