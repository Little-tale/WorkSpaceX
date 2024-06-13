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
        case checkedLogin
    }
    
    @Dependency(\.userDomainRepository) var repository
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.onboard = OnboardingLoginFeature.State()
                // 뭐가 있을거임.
//                return .run { send in
//                    await send(.testSuccess)
//                }
                return .none
            case .onboardingLoginFeature(.presented(.appleLoginFinish)): // 애플 로그인시
            
                return .run { send in
                    await send(.testSuccess)
                }
            case .onboardingLoginFeature(.presented(.kakaoLoginFinish)): // 카카오 로그인 시
                
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .onboardingLoginFeature(.presented(.signUpFeature(.presented(.onlyUseParentsUserEntity(let user))))):
                print("signUpFeatureEvents: \(user)")
                
                return .run { send in
                    await send(.testSuccess)
                }
                
            case .onboardingLoginFeature(.presented(.emailLoginFeature(.presented(.loginSuccess)))): // 이메일 로그인시
                print("이메일 로그인 성공 상위뷰 전달 받음")
                return .run { send in
                    await send(.checkedLogin)
                }
                
            case .testSuccess:
                if ifLogin() {
                    return .run { send in await send(.checkedLogin)}
                } else {
                    state.loginFalid = "로그인중 문제가 발생했습니다 재시도 바랍니다."
                }
                return .none
                
            case .checkedLogin:
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
        if UserDefaultsManager.refreshToken == nil {
            return false
        }
        if UserDefaultsManager.accessToken == nil {
            return false
        }
        return true
    }
    
}
