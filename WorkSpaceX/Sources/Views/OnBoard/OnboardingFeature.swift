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
        var loginFail: String?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startButtonTapped
        case onboardingLoginFeature(PresentationAction<OnboardingLoginFeature.Action>)
        case testSuccess
        case checkedLogin
    }
    
    @Dependency(\.userDomainRepository) var repository
    @Dependency(\.realmRepository) var realmeRepo

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        core()
        .ifLet(\.$onboard, action:\.onboardingLoginFeature) {
            OnboardingLoginFeature()
        }
    }
}

extension OnboardingFeature {
    
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.onboard = OnboardingLoginFeature.State()

            case .onboardingLoginFeature(.presented(.delegate(.appleLoginFinish(let model)))): // 애플 로그인시
                
                return socialLoginSuccessSideEffect(model: model)
            case .onboardingLoginFeature(.presented(.delegate(.kakaoLoginFinish(let model)))): // 카카오 로그인 시
                
                return socialLoginSuccessSideEffect(model: model)
            case .onboardingLoginFeature(.presented(.signUpFeature(.presented(.onlyUseParentsUserEntity(let model))))):
                print("signUpFeatureEvents: \(model)")
                
                return socialLoginSuccessSideEffect(model: model)
            case .onboardingLoginFeature(.presented(.emailLoginFeature(.presented(.loginSuccess(let model))))): // 이메일 로그인시
                print("이메일 로그인 성공 상위뷰 전달 받음")
                return socialLoginSuccessSideEffect(model: model)
                
            case .testSuccess:
                if ifLogin() {
                    
                    return .send(.checkedLogin)
                    
                } else {
                    state.loginFail = "로그인중 문제가 발생했습니다 재시도 바랍니다."
                }
    
            default :
                break
            }
            
            return .none
        }
    }
    
}

extension OnboardingFeature {
    
    private func socialLoginSuccessSideEffect(model: UserEntity) -> Effect<Action> {
        return .run { send in
            try await realmeRepo.upsertUserModel(response: model)
            await send(.testSuccess)
        } catch: { error , send in
           print(error)
        }
    }
}


extension OnboardingFeature {
    
    private func ifLogin() -> Bool {
        if UserDefaultsManager.accessToken == nil {
            return false
        }
        return true
    }
    
}
