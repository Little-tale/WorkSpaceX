//
//  WorkSpaceEmptyListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceEmptyListFeature {
    
    @ObservableState
    struct State: Equatable {
        var title = "Work Space 가 없어요 ㅠㅠ"
        var message = "관리자에게 초대를 요청하거나, 다른 이메일로 시도 또는 새로운 워크스페이스를 생성해주세요."
        @Presents var worSpaceIniter: WorkSpaceInitialFeature.State?
    }
    
    enum Action {
        case startButtonTapped
        case sendWorkSpaceInit(PresentationAction<WorkSpaceInitialFeature.Action>)
        case regSuccess
        case openSideMenu
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case .startButtonTapped:
                state.worSpaceIniter = WorkSpaceInitialFeature.State()
                return .none
                
            case .sendWorkSpaceInit(.presented(.regSuccess)):
                
                return .run { send in
                    await send(.regSuccess)
                }
                
            default :
                break
            }
            
            return .none
        }
        .ifLet(\.$worSpaceIniter, action: \.sendWorkSpaceInit) {
            WorkSpaceInitialFeature()
        }
        
    }
}

