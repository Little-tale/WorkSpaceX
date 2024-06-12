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
    
    enum Tab: Equatable {
        case home, dm, search, setting
        
        var title: String {
            return switch self {
            case .home:
                "홈"
            case .dm:
                "DM"
            case .search:
                "검색"
            case .setting:
                "설정"
            }
        }
    }
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.home
        // 만약 워크 스페이스가 없을시
        var makeSpaceViewState = WorkSpaceEmptyListFeature.State()
        var homeState = WorkSpaceListFeature.State()
        var ifNoneSpace = true
    }
    
    enum Action {
        case homeAction(WorkSpaceListFeature.Action)
        case selectedTab(Tab)
        case ifNeedMakeWorkSpace(WorkSpaceEmptyListFeature.Action)
        case appear
    }
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.makeSpaceViewState, action: \.ifNeedMakeWorkSpace) {
            WorkSpaceEmptyListFeature()
        }
        
        Scope(state: \.homeState, action: \.homeAction) {
            WorkSpaceListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .selectedTab(let tab):
                state.currentTab = tab
                return .none
            case .ifNeedMakeWorkSpace:
                return .none
                
            case .appear:
                
                return .none
            }
        }
        
    }
    
}
