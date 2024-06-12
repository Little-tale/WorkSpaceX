//
//  RootFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//


import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    
    enum CheckFor {
        case none
        case ifNeedChecked
    }
    
    @ObservableState
    struct State {
        var currentLoginState: loginState = .logout
        var workWpaceFirstViewState: WorkSpaceFirstStartFeature.State?
        var OnboardingViewState: OnboardingFeature.State?
       
    }
    
    enum loginState {
        case login
        case logout
        case firstLogin
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case sendToWorkSpaceStart(WorkSpaceFirstStartFeature.Action)
        case sendToOnboardingView(OnboardingFeature.Action)
        
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {state, action in
            switch action {
            case .onAppear :
                if let _ = UserDefaultsManager.accessToken {
                    if UserDefaultsManager.isFirstUser {
                        state.workWpaceFirstViewState = WorkSpaceFirstStartFeature.State()
                        state.currentLoginState = .firstLogin
                    } else {
                        // 여기에 알지?
                        state.currentLoginState = .login
                    }
                } else {
                    state.OnboardingViewState = OnboardingFeature.State()
                    state.currentLoginState = .logout
                }
                return .none
            case .sendToWorkSpaceStart(.sendWorkSpaceInit(.presented(.goRootCheck))):
                print("작동하는가..?")
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceStart(.cancelButtonTapped):
                return .run { send in await send(.onAppear) }
                
            case .sendToOnboardingView(.checkedLogin):
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceStart:
                
                return .none
                
            case .binding:
                
                return .none
            case .sendToOnboardingView:
                
                return .none
            }
        }
        .ifLet(\.workWpaceFirstViewState, action: \.sendToWorkSpaceStart) {
            WorkSpaceFirstStartFeature()
        }
        .ifLet(\.OnboardingViewState, action: \.sendToOnboardingView) {
            OnboardingFeature()
        }
    
    }
    
}


