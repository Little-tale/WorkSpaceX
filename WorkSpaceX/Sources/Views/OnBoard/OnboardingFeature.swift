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
    }
    
    enum Action {
        case startButtonTapped
        case onboardingLoginFeature(PresentationAction<OnboardingLoginFeature.Action>)
        
    }
    
    @Dependency(\.userDomainRepository) var repository
    
    var body: some ReducerOf<Self> {

        
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.onboard = OnboardingLoginFeature.State()
                // 뭐가 있을거임.
                return .none
                
            case .onboardingLoginFeature(.presented(.appleLoginFinish(let user))): // 애플 로그인시
                
                
                return .none
            case .onboardingLoginFeature(.presented(.kakaoLoginFinish(let user))): // 카카오 로그인 시
                
                
                return .none
            case .onboardingLoginFeature(.presented(.signUpFeature(.presented(.onlyUseParentsUserEntity(let user))))):
                print("signUpFeatureEvents: \(user)")
                return .none // 가입 후 시
                
            case .onboardingLoginFeature(.presented(.emailLoginFeature(.presented(.loginSuccess(let user))))): // 이메일 로그인시
                
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
