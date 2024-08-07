//
//  OnboardingLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct OnboardingLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp: SignUpFeature.State?
        @Presents var emailLogin: EmailLoginFeature.State?
        var viewText = ViewText()
        var errorPresentation: String? = nil
    }
    
    struct ViewText: Equatable {
        let also = "또는"
        let newUser = "새롭게 회원가입 하기"
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var repository
    @Dependency(\.kakaoLoginManager) var kakaoLogin
    @Dependency(\.appleLoginErrorHandler) var isUserErrorApple
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        
        case emailLoginButtonTapped
        case emailLoginFeature(PresentationAction<EmailLoginFeature.Action>)
        
        case newSignUpTapped
        case signUpFeature(PresentationAction<SignUpFeature.Action>)
        
        case kakaoLoginSuccess(Result<String,KakaoLoginErrorCase>)
        case errorMessage(message: String?)
        
        case delegate(Delegate)
        
        enum Delegate {
            case appleLoginFinish(UserEntity)
            case kakaoLoginFinish(UserEntity)
        }
    }
    
    
    struct appleLoginInfo {
        let id: String
        let name: String
    }
    
    var body: some ReducerOf<Self> {
        core()
        .ifLet(\.$signUp, action: \.signUpFeature) {
            SignUpFeature()
        }
        .ifLet(\.$emailLogin, action: \.emailLoginFeature) {
            EmailLoginFeature()
        }
    }
}

extension OnboardingLoginFeature {
    
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:
                
                return appleLoginSideEffect(state: &state)
            case .kakaoLoginButtonTapped:
                
                return kakaoLoginSideEffect(state: &state)
            case .kakaoLoginSuccess(let result):
               
                return kakaoLoginResultSideEffect(state: &state, result: result)
            case .emailLoginButtonTapped:
                state.emailLogin = EmailLoginFeature.State()
                
            case let .emailLoginFeature(loginFeature):
                if case .dismiss = loginFeature {
                    
                    return dismissEffect()
                }
                
            case .newSignUpTapped:
                state.signUp = SignUpFeature.State()
                
            case let .signUpFeature(childReducer):
                if case .dismiss = childReducer {
                    return dismissEffect()
                }
                
            case .errorMessage(message: let messgage):
                state.errorPresentation = messgage
                
            default:
                break
            }
            return .none
        }
    }
}
//MARK: SideEffect
extension OnboardingLoginFeature {
    
    private func appleLoginSideEffect(state: inout State) -> Effect<Action> {
        return .run { send in
            let success = try await repository.appleLoginRequest()
            await send(.delegate(.appleLoginFinish(success)))
        } catch: { error, send in
            if let error = error as? AppleLoginAPIError {
                if !error.ifDevelopError {
                    await send(.errorMessage(message: error.message))
                }
            } else {
                await send(.errorMessage(message: APIError.Unknown))
                print(error)
            }
        }
    }
    
    private func kakaoLoginSideEffect(state: inout State) -> Effect<Action> {
        return .run { send in
            let result = await kakaoLogin.requestKakao()
            await send(.kakaoLoginSuccess(result))
        }
    }
    
    private func kakaoLoginResultSideEffect(state: inout State, result: Result<String, KakaoLoginErrorCase>) -> Effect<Action> {
        switch result {
        case .success(let success):
            return .run { send in
                let result = try await  repository.requestKakaoUser((success, ""))
                
                await send(.delegate(.kakaoLoginFinish(result)))
            } catch: { error, send in
                if let error = error as? KakaoLoginAPIError {
                    if !error.ifDevelopError {
                        await send(.errorMessage(message: error.message))
                    }
                } else {
                    await send(.errorMessage(message: APIError.Unknown))
                }
            }
        case .failure(let error):
            switch error {
            case .cancel:
                return .none
            case .error:
                return .send(.errorMessage(message: error.message))
            }
        }
    }
}

extension OnboardingLoginFeature {
    private func dismissEffect() -> Effect<Action> {
        return .run { send in
            await self.dismiss()
        }
    }
}
