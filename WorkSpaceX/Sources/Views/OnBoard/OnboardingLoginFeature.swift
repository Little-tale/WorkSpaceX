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


@Reducer
struct OnboardingLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp: SignUpFeature.State?
        @Presents var emailLogin: EmailLoginFeature.State?
        var errorPresentation: String? = nil
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var repository
    
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
    
//        case kakaoLoginResult(Result<UserEntity, UserDomainError>)
//        case kakaoLoginErrorHandler(KakaoLoginAPIError)
        
        case appleLoginFinish(UserEntity)
        case kakaoLoginFinish(UserEntity)
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

extension OnboardingLoginFeature {
    
    private func requestKakao(
        result: @escaping (Result<String, KakaoLoginErrorCase>) -> Void
    ) {
        DispatchQueue.main.async {
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    print("에러가 발생하였는가???",error)
                    if let error {
                        let results = checkKakaoError(error: error)
                        result(.failure(results))
                    } else if let oauthToken {
                        print("카카오톡 성공 \(oauthToken)")
                        result(.success(oauthToken.accessToken))
                    } else {
                        result(.failure(.error(.init(apiFailedMessage: "FAIL KAKAO"))))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    print("에러가 발생하였는가??? 여기?",error)
                    if let error {
                        let results = checkKakaoError(error: error)
                        result(.failure(results))
                    } else if let oauthToken {
                        print("카카오톡 성공 \(oauthToken)")
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
            print("카카오 에러 \(error)")
            return .error(error)
        }
        return .cancel
    }
}

//            case .kakaoLoginResult(let result):
//
//                return .run { send in
//                    switch result {
//                    case .success(let success):
//                        print("성공",success)
//                        await send(.kakaoLoginFinish(success))
//                    case .failure(let error):
//                        await send(.userDomainErrorHandler(error))
//                    }
//                }
//            case .userDomainErrorHandler(let error):
//                switch error {
//                case .commonError(let error):
//                    if !error.ifDevelopError {
//                        return .run { send in
//                            await send(.errorMessage(messgage: error.message))
//                        }
//                    }
/*
 case .kakaoLogin:
     if !error.ifDevelopError {
         return .run { send in
             await send(.errorMessage(messgage: error.message))
         }
     }
 default :
     return .none
 }
 */
