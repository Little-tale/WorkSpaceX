//
//  OnboardingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var onboard: OnboardingLoginFeature.State?
        var loginFalid: String?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startButtonTapped
        case onboardingLoginFeature(PresentationAction<OnboardingLoginFeature.Action>)
        case testSuccess
    }
    
    @Dependency(\.userDomainRepository) var repository
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.onboard = OnboardingLoginFeature.State()
                // 뭐가 있을거임.
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .onboardingLoginFeature(.presented(.appleLoginFinish(let user))): // 애플 로그인시
                
                 state.loginFalid = "테스트"
                return .run { send in
                    await send(.testSuccess)
                }
            case .onboardingLoginFeature(.presented(.kakaoLoginFinish(let user))): // 카카오 로그인 시
                
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .onboardingLoginFeature(.presented(.signUpFeature(.presented(.onlyUseParentsUserEntity(let user))))):
                print("signUpFeatureEvents: \(user)")
                
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .onboardingLoginFeature(.presented(.emailLoginFeature(.presented(.loginSuccess(let user))))): // 이메일 로그인시
                
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .testSuccess:
                if ifLogin() {
                    
                } else {
                    
                }
                return .none
                
            default :
                return .none
            }
        }
        .ifLet(\.$onboard, action:\.onboardingLoginFeature) {
            OnboardingLoginFeature()
        }
    }
}


extension OnboardingFeature {
    
    private func ifLogin() -> Bool {
        
        guard let access = UserDefaultsManager.accessToken,
              let refresh = UserDefaultsManager.refreshToken else {
            return false
        }
        
        return true
    }
    
}
