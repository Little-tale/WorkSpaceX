//
//  DMSCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct DMSCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<DMSCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.identeRoutes, action: \.router)) { screen in
                switch screen.case {
                case let .dmHome(store):
                    DMSListView(store: store)
                }
            }
        }
    }
    
}

extension DMSListScreens.State: Identifiable {
    var id: UUID {
        switch self {
        case let .dmHome(state):
            return state.id
        }
    }
}
