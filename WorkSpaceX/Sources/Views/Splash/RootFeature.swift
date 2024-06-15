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
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
//        Scope(state: \.workSpaceTabViewState, action: \.sendToWorkSpaceTab) {
//            WorkSpaceTabCoordinator()
//        }
        
        Reduce {state, action in
            switch action {
            case .onAppear :
                
                if let _ = UserDefaultsManager.accessToken {
                    if UserDefaultsManager.isFirstUser {
                        state.workWpaceFirstViewState = WorkSpaceFirstStartFeature.State()
                        state.currentLoginState = .firstLogin
                    } else {
                        // 여기에 알지?
                        state.workSpaceTabViewState = .initalState
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
                
//            case .sendToWorkSpaceTab(.delegate(.checkRootView)):
//                
//                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceStart(.cancelButtonTapped):
                
                return .run { send in await send(.onAppear) }
                
            case .sendToOnboardingView(.checkedLogin):
                print("엥??????")
                return .run { send in await send(.onAppear) }
                
            case .sendToWorkSpaceStart:
                
                return .none
                
            case .binding:
                
                return .none
            case .sendToOnboardingView:
                
                return .none
            case .sendToWorkSpaceTab:
                return .none
                
            case .alert(.dismiss):
                return .none
                
            case .alert(.presented(.refreshTokkenDead)):
                
                return .run { send in
                    await send(.onAppear)
                }
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

/*
 NotificationCenter.default.addObserver(
     forName: .ifNeedReChack,
     object: nil,
     queue: .main) { _ in
         print("한번씩만...")
         store.send(.onAppear)
     }
 */
