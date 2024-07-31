//
//  WorkSpaceFirstStartFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceFirstStartFeature {
    
    @ObservableState
    struct State {
        var introText = "새로운 WorkSpaceX의 워크 스페이스를\n 시작할 준비가 되었어요!"
        var readyText = "출시 준비 완료!"
        var navigationTitle = "시작하기"
        var workSpaceMakeText = "워크 스페이스 생성"
        @Presents var workSpaceInitial: WorkSpaceInitialFeature.State?
    }
    
    enum Action {
        case onAppear
        case startButtonTapped
        case cancelButtonTapped
        case sendWorkSpaceInit(PresentationAction<WorkSpaceInitialFeature.Action>)
    }
    
    
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let name = UserDefaultsManager.userName {
                    state.introText =  name + "님! 새로운 WorkSpaceX의 워크 스페이스를\n 시작할 준비가 되었어요!"
                }
                UserDefaultsManager.isFirstUser = false
                return .none
            case .startButtonTapped:
                state.workSpaceInitial = WorkSpaceInitialFeature.State()
                
            default:
                break
            }
            return .none
        }
        .ifLet(\.$workSpaceInitial, action: \.sendWorkSpaceInit) {
            WorkSpaceInitialFeature()
        }
    }
}
