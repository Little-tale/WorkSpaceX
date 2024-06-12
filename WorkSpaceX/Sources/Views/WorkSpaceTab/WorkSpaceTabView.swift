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
                
                Text("홈뷰").tabItem { Text("Tab Label 1") }.tag(WorkSpaceXTabFeature.Tab.home)
                
                Text("DM").tabItem { Text("Tab Label 2") }.tag(WorkSpaceXTabFeature.Tab.dm)
                
                Text("search").tabItem { Text("Tab Label 3") }.tag(WorkSpaceXTabFeature.Tab.search)
                
                Text("setting").tabItem { Text("Tab Label 4") }.tag(WorkSpaceXTabFeature.Tab.setting)
            
            }
        }
    }
}

#Preview {
    WorkSpaceTabView(store: Store(initialState: { WorkSpaceXTabFeature.State()}(), reducer: {
        WorkSpaceXTabFeature()
    }))
}
