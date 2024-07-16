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
        var workSpaceTabViewState: WorkSpaceTabCoordinator.State?
        @Presents var alert: AlertState<Action.Alert>?
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
        case sendToWorkSpaceTab(WorkSpaceTabCoordinator.Action)
        
        @CasePathable
        enum Alert {
            case refreshTokkenDead
        }
        case alert(PresentationAction<Alert>)
        
        case showRefreshAlert
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
                        state.workSpaceTabViewState =  WorkSpaceTabCoordinator.State.initalState
                        state.currentLoginState = .login
                    }
                } else {
                    state.OnboardingViewState = OnboardingFeature.State()
                    state.currentLoginState = .logout
                }
                
                return .none
            case .sendToWorkSpaceStart(.sendWorkSpaceInit(.presented(.goRootCheck))):
                
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceStart(.cancelButtonTapped):
                
                return .run { send in await send(.onAppear) }
                
            case .sendToOnboardingView(.checkedLogin):
             
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceTab(.noWorkSpaceTrigger) :
                
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceTab(.delegate(.moveToOnBoardingView)):
                state.currentLoginState = .logout
                return .none
                
            case .sendToWorkSpaceTab(.refreshChecked):
                state.OnboardingViewState = OnboardingFeature.State()
                state.currentLoginState = .logout
                
                return .none
            case .sendToWorkSpaceTab:
                return .none
                
            case .alert(.dismiss):
                return .none
                
            case .showRefreshAlert:
                state.alert = AlertState.refreshDeadAlert
                return .none
    
            case .alert(.presented(.refreshTokkenDead)):
                state.OnboardingViewState = OnboardingFeature.State()
                state.currentLoginState = .logout

                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.workWpaceFirstViewState, action: \.sendToWorkSpaceStart) {
            WorkSpaceFirstStartFeature()
        }
        .ifLet(\.OnboardingViewState, action: \.sendToOnboardingView) {
            OnboardingFeature()
        }
        .ifLet(\.workSpaceTabViewState, action: \.sendToWorkSpaceTab) {
            WorkSpaceTabCoordinator()
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
}
