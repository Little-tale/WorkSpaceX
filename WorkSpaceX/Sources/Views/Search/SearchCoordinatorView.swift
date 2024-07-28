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
                case let .channelChatView(store):
                    WorkSpaceChannelChattingView(store: store)
                case let .otherProfileView(store):
                    ProfileInfoView(store: store)
                case let .chatChannelSettingView(store):
                    ChatChannelSettingView(store: store)
                case let .channelEdit(store):
                    ChannelEditView(store: store)
                case let .ChannelOwnerChange(store):
                    ChannelOwnerChangeView(store: store)
                }
            }
        }
    }
}

extension SearchListScreens.State: Identifiable {
    var id: UUID {
        switch self {
        case let .home(state):
            return state.id
        case let .channelChatView(state):
            return state.id
        case let .otherProfileView(state):
            return state.id
        case let .chatChannelSettingView(state):
            return state.id
        case let .channelEdit(state):
            return state.id
        case let .ChannelOwnerChange(state):
            return state.id
        }
    }
}
