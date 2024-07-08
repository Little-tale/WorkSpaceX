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
                case let .memberAdd(store):
                    AddMemberView(store: store)
                case let .dmChat(store):
                    DMSChatView(store: store)
                case let .profileInfo(store):
                    ProfileInfoView(store: store)
                case let .profileEdit(store):
                    ProfileInfoEditView(store: store)
                case let .storeListView(store):
                    StoreListView(store: store)
//                case let .document(store):
//                    DocumentView(store: store)
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
        case let .memberAdd(state):
            return state.id
        case let .dmChat(state):
            return state.id
        case let .profileInfo(state):
            return state.id
        case let .profileEdit(state):
            return state.id
        case let .storeListView(state):
            return state.id
//        case let .document(state):
//            return state.id
            
        }
    }
}
