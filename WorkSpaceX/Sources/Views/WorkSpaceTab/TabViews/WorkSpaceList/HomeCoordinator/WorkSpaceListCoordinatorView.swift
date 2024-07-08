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
                    
                case let .chattingView(store):
                    WorkSpaceChannelChattingView(store: store)
                    
                case let .chatChannelSettingView(store):
                    ChatChannelSettingView(store: store)
                    
                case let .chatnnelEdit(store):
                    ChannelEditView(store: store)
                    
                case let .ChannelOwnerChange(store):
                    ChannelOwnerChangeView(store: store)
                    
                case let .profileInfo(store):
                    ProfileInfoView(store: store)
    
                case let .profileEdit(store):
                    ProfileInfoEditView(store: store)
                    
                case let .storeListView(store):
                    StoreListView(store: store)
                    
                case let .dmChat(store):
                    DMSChatView(store: store)
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
        case let .chattingView(state):
            return state.id
        case let .chatChannelSettingView(state):
            return state.id
        case let .chatnnelEdit(state):
            return state.id
        case let .ChannelOwnerChange(state):
            return state.id
        case let .profileInfo(state):
            return state.id
        case let .profileEdit(state):
            return state.id
        case let .storeListView(state):
            return state.id
        case let .dmChat(state):
            return state.id
            
        }
    }
}
