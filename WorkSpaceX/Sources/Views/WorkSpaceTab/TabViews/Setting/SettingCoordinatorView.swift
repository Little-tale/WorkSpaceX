//
//  SettingCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/7/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct SettingCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<SettingCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.identeRoutes, action: \.router)) { screen in
                switch screen.case {
                case .profileEdit(let store):
                    ProfileInfoEditView(store: store)
                case .storeListView(let store):
                    StoreListView(store: store)
                case .home(let store):
                    ProfileInfoView(store: store)
                }
            }
        }
    }
}

extension SettingScreens.State: Identifiable {
    
    var id: UUID {
        switch self {
        case .home(let state):
            return state.id
        case .profileEdit(let state):
            return state.id
        case .storeListView(let state):
            return state.id
        }
    }
}
