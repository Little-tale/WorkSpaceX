//
//  SearchCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct SearchCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<SearchCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.identeRoutes, action: \.router)) { viewCase in
                switch viewCase.case {
                case let .home(store):
                    SearchView(store: store)
                }
            }
        }
    }
}

extension SearchListScreens.State: Identifiable {
    var id: UUID {
        switch self {
        case .home(let state):
            return state.id
        }
    }
}
