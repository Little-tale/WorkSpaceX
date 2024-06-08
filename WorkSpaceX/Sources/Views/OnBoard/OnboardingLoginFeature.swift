//
//  OnboardingLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture
import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Combine

@Reducer
struct OnboardingLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp: SignUpFeature.State?
        var errorPresentation: String? = nil
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var repository
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        case emailLoginButtonTapped
        case newSignUpTapped
        case signUpFeature(PresentationAction<SignUpFeature.Action>)
        case kakaoLoginSuccess(Result<String,KakaoLoginErrorCase>)
        case errorMessage(messgage: String?)
    
        case loginResult(Result<UserEntity, UserDomainError>)
        case userDomainErrorHandler(UserDomainError)
    }
    
    enum KakaoLoginErrorCase: Error {
        case cancel
        case error(SdkError)
        
        var message: String {
            switch self {
            case .cancel:
                return ""
            case .error(_):
                return "KAKAO 로그인 실패\n재시도 바랍니다."
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:
                
                return .none
            case .kakaoLoginButtonTapped:
                
                return .run { send in
                    let result = await withCheckedContinuation { contination in
                        requestKakao { result in
                            contination.resume(returning: result)
                        }
                    }
                    await send(.kakaoLoginSuccess(result))
                }
            case .kakaoLoginSuccess(let result):
               
                switch result {
                    
                case .success(let success):
            
                    return .run { send in
                        let result = await  repository.requestKakaoUser((success, ""))
                        await send(.loginResult(result))
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
            case .loginResult(let result):
                
                return .run { send in
                    switch result {
                    case .success(let success):
                        print(success)
                    case .failure(let error):
                        await send(.userDomainErrorHandler(error))
                    }
                }
            case .userDomainErrorHandler(let error):
                switch error {
                case .commonError(let error):
                    if !error.ifDevelopError {
                        return .run { send in
                            await send(.errorMessage(messgage: error.message))
                        }
                    }
                case .kakaoLogin:
                    if !error.ifDevelopError {
                        return .run { send in
                            await send(.errorMessage(messgage: error.message))
                        }
                    }
                default :
                    break
                }
                return .none
            }
            
        }
        .ifLet(\.$signUp, action: \.signUpFeature) {
            SignUpFeature()
        }
    }
}

extension OnboardingLoginFeature {
    
    private func requestKakao(
        result: @escaping (Result<String, KakaoLoginErrorCase>) -> Void
    ) {
        DispatchQueue.main.async {
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error {
                        let result = checkKakaoError(error: error)
                    } else if let oauthToken {
                        result(.success(oauthToken.accessToken))
                    } else {
                        result(.failure(.error(.init(apiFailedMessage: "FAIL KAKAO"))))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error {
                        let result = checkKakaoError(error: error)
                    } else if let oauthToken {
                        result(.success(oauthToken.accessToken))
                    } else {
                        result(.failure(.error(.init(apiFailedMessage: "FAIL KAKAO"))))
                    }
                }
            }
        }
    }
    
    private func checkKakaoError(error: Error) -> KakaoLoginErrorCase {
        
        guard let error = error as? SdkError else {
            return .error(.init(apiFailedMessage: "알수 없는 에러"))
        }
        if !error.isClientFailed {
            return .error(error)
        }
        return .cancel
    }
}

/*
 if let error {
 await send(.kakaoLoginSuccess(.failure(error)))
 } else if let oauthToken {
 await send(.kakaoLoginSuccess(.success(oauthToken.accessToken)))
 }
 */



/*
 case let .kakaoLoadSuccess(kakao):
 return .run { send in
 let result = try await repository.requestKakaoUser((kakao, ""))
 print("Success",result)
 }
 */
