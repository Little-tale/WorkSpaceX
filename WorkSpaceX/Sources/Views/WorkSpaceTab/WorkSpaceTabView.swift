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
            TabView(selection: $store.currentTab.sending(\.selectedTab)) {
                
                WorkSpaceListView(
                    store: store.scope(state: \.homeState, action: \.homeAction)
                )
                .tag(WorkSpaceXTabFeature.Tab.home)
                .tabItem { Text("Tab Label 1") }
                
                
                Text("DM").tabItem {
                    Text("Tab Label 2") }.tag(WorkSpaceXTabFeature.Tab.dm)
                
                Text("search").tabItem {
                    Text("Tab Label 3") }.tag(WorkSpaceXTabFeature.Tab.search)
                
                Text("setting").tabItem {
                    Text("Tab Label 4") }.tag(WorkSpaceXTabFeature.Tab.setting)
                
            }
        }
    }
}

#Preview {
    WorkSpaceTabView(store: Store(initialState: { WorkSpaceXTabFeature.State()}(), reducer: {
        WorkSpaceXTabFeature()
    }))
}
