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
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case homeAction(WorkSpaceListFeature.Action)
        case selectedTab(Tab)
        case ifNeedMakeWorkSpace(WorkSpaceEmptyListFeature.Action)
        
        case appear
        case refreshDead
        
        enum Delegate {
            case checkRootView
            case currentSpaces([WorkSpaceEntity])
            case refreshDead
        }
        case delegate(Delegate)
        
        @CasePathable
        enum Alert {
            case refreshTokkenDead
        }
        case alert(PresentationAction<Alert>)
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
            case .alert(.presented(.refreshTokkenDead)):
                
                return .run{ send in
                    await send(.delegate(.checkRootView))
                }
                
            case .alert(.dismiss):
                return .none
                
            case .selectedTab(let tab):
                state.currentTab = tab
                return .none
                
            case .ifNeedMakeWorkSpace:
                
                return .none
                

            case .appear:
    
                return .run { send in
                    let result = try await workSpaceRepo.findMyWordSpace()
                    print("현재 스페이스 갯수")
                    dump(result)
                    await send(.delegate(.currentSpaces(result)))
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceMeError {
                        if error.ifReFreshDead {
                            print(error)
                            await send(.refreshDead)
                        }
                        if error.ifDevelopError {
                            print(error.message)
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case .refreshDead:
                state.alert = .refreshDeadAlert
                return .none
                
            case .delegate:
                
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        
    }
    
}


extension AlertState where Action == WorkSpaceXTabFeature.Action.Alert {
    
    static let refreshDeadAlert = Self {
        TextState("재 로그인 필요")
    } actions: {
        ButtonState(role: .destructive, action: .refreshTokkenDead) {
            TextState("확인")
        }
    } message: {
        TextState("로그인 시간이 만료되어 재로그인이 필요합니다 ㅠㅠ")
    }

}
