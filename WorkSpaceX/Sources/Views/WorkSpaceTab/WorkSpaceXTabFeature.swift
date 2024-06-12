//
//  WorkSpaceXTabFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture


@Reducer
struct WorkSpaceXTabFeature {
    
    enum Tab{ case home, dm, search, setting }
    
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.home
        var homeState = WorkSpaceListFeature.State()
    }
    
    enum Action {
        case homeAction(WorkSpaceListFeature.Action)
        case selectedTab(Tab)
    }
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.homeState, action: \.homeAction) {
            WorkSpaceListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .selectedTab(let tab):
                state.currentTab = tab
                return .none
            }
            
        }
    }
    
}
