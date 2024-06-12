//
//  WorkSpaceTabView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceTabView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceXTabFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            
            Group {
                if store.state.ifNoneSpace {
                    NavigationStack {
                        WorkSpaceEmptyListView(store: store.scope(state: \.makeSpaceViewState, action: \.ifNeedMakeWorkSpace))
                    }
                    
                } else {
                    TabView(selection: $store.currentTab.sending(\.selectedTab)) {
                        WorkSpaceListView(
                            store: store.scope(state: \.homeState, action: \.homeAction)
                        )
                        .tag(WorkSpaceXTabFeature.Tab.home)
                        .tabItem {
                            WSXImage.homeImage.renderingMode(.template)
                            Text(WorkSpaceXTabFeature.Tab.home.title)
                        }
                        
                        Text("DM")
                            .tabItem {
                                Text(WorkSpaceXTabFeature.Tab.dm.title) }.tag(WorkSpaceXTabFeature.Tab.dm)
                        
                        Text("search")
                            .tabItem {
                                Text(WorkSpaceXTabFeature.Tab.search.title) }.tag(WorkSpaceXTabFeature.Tab.search)
                        
                        Text("setting")
                            .tabItem {
                                Text(WorkSpaceXTabFeature.Tab.setting.title) }.tag(WorkSpaceXTabFeature.Tab.setting)
                        
                    }
                    .tint(WSXColor.black)
                }
            }
            .onAppear {
                store.send(.appear)
            }
           
        }
    }
}

#Preview {
    WorkSpaceTabView(store: Store(initialState: { WorkSpaceXTabFeature.State()}(), reducer: {
        WorkSpaceXTabFeature()
    }))
}
