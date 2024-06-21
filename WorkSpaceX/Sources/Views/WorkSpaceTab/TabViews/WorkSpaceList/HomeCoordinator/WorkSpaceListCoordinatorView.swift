//
//  WorkSpaceListCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct WorkSpaceListCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceListCordinator>

    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.identeRoutes, action: \.router)) { screen in
                
                switch screen.case {
                case let .rootScreen(store):
                    WorkSpaceListView(store: store)
                    
                case let .channelAdd(store):
                    WorkSpaceChannelAddView(store: store)
                    
                case let .memberAdd(store):
                    AddMemberView(store: store)
                    
                case let .workSpaceChannelListView(store):
                    WorkSpaceChannelListView(store: store)
                }
            }
        }
    }
}

extension WorkSpaceListScreens.State: Identifiable {
    var id: UUID {
        switch self {
        case let .rootScreen(state):
            return state.id
        case let .channelAdd(state):
            return state.id
        case let .memberAdd(state):
            return state.id
        case let .workSpaceChannelListView(state):
            return state.id
        }
    }
}
