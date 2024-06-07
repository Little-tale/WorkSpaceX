//
//  OnboardingLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture
import Foundation
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
        case kakaoLoginSuccess(Result<String,Error>)
        case errorMessage(messgage: String?)
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
                case .success(let token):
//                    state.oauthToken = token
//                    state.errorPresentation = nil
                    return .none
                case .failure:
                    state.errorPresentation = "카카오 로그인 실패\n재시도 해주세요!"
                }
                return .none
            
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
            }
            
        }
        .ifLet(\.$signUp, action: \.signUpFeature) {
            SignUpFeature()
        }
    }
}

extension OnboardingLoginFeature {
    
    func requestKakao(result: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error {
                        result(.failure(error))
                    } else if let oauthToken {
                        result(.success(oauthToken.accessToken))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    
                    if let error {
                        result(.failure(error))
                    } else if let oauthToken {
                        result(.success(oauthToken.accessToken))
                    }
                    
                }
            }
        }
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
