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
    @Dependency(\.appleLoginErrorHandeler) var isUserErrorApple
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        
        case emailLoginButtonTapped
        case emailLoginFeature(PresentationAction<EmailLoginFeature.Action>)
        
        case newSignUpTapped
        case signUpFeature(PresentationAction<SignUpFeature.Action>)
        
        case kakaoLoginSuccess(Result<String,KakaoLoginErrorCase>)
        case errorMessage(messgage: String?)
        
        case appleLoginFinish(UserEntity)
        case kakaoLoginFinish(UserEntity)
    }
    
    
    struct appleLoginInfo {
        let id: String
        let name: String
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:

                return .run { send in
                    let success = try await repository.appleLoginRequest()
                    await send(.appleLoginFinish(success))
                } catch: { error, send in
                    if let error = error as? AppleLoginAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(messgage: error.message))
                        }
                    } else {
                        await send(.errorMessage(messgage: APIError.Unkonwn))
                        print(error)
                    }
            
                }
            case .kakaoLoginButtonTapped:
                return .run { send in

                    let result = await kakaoLogin.reqeustKakao()
                    await send(.kakaoLoginSuccess(result))
                }
            case .kakaoLoginSuccess(let result):
               
                switch result {
                    
                case .success(let success):
            
                    return .run { send in
                        let result = try await  repository.requestKakaoUser((success, ""))
                        
                        await send(.kakaoLoginFinish(result))
                    } catch: { error, send in
                        if let error = error as? KakaoLoginAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(messgage: error.message))
                            }
                        } else {
                            await send(.errorMessage(messgage: APIError.Unkonwn))
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .cancel:
                        return .none
                    case .error:
                        return .send(.errorMessage(messgage: error.message))
                    }
                }
                
                
            case .emailLoginButtonTapped:
                state.emailLogin = EmailLoginFeature.State()
                return .none
                
            case let .emailLoginFeature(loginFeature):
                if case .dismiss = loginFeature {
                    return .run { send in
                        await self.dismiss()
                    }
                }
                return .none
                
            case .newSignUpTapped:
                state.signUp = SignUpFeature.State()
                
                return .none
                
            case let .signUpFeature(childReducer):
                
                if case .dismiss = childReducer {
                    return .run { send in
                        await self.dismiss()
                    }
                }
                return .none
                
            case .errorMessage(messgage: let messgage):
                state.errorPresentation = messgage
                return .none
          
            case .appleLoginFinish: // 부모에서
                return .none
            case .kakaoLoginFinish: // 부모에서
                return .none
            }
        }
        .ifLet(\.$signUp, action: \.signUpFeature) {
            SignUpFeature()
        }
        .ifLet(\.$emailLogin, action: \.emailLoginFeature) {
            EmailLoginFeature()
        }
    }
}
