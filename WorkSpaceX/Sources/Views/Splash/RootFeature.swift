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
        var workSpaceFirstViewState: WorkSpaceFirstStartFeature.State?
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
            case refreshTokenDead
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
                        state.workSpaceFirstViewState = WorkSpaceFirstStartFeature.State()
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
                
            case .sendToWorkSpaceTab(.refreshChecked):
                state.OnboardingViewState = OnboardingFeature.State()
                state.currentLoginState = .logout
                
            case .showRefreshAlert:
                state.alert = AlertState.refreshDeadAlert
    
            case .alert(.presented(.refreshTokenDead)):
                state.OnboardingViewState = OnboardingFeature.State()
                state.currentLoginState = .logout
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.workSpaceFirstViewState, action: \.sendToWorkSpaceStart) {
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
