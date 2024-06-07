//
//  OnboardingLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture
import KakaoSDKAuth
import KakaoSDKUser

@Reducer
struct OnboardingLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp: SignUpFeature.State?
        
    }
    
    @Dependency(\.dismiss) var dismiss
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        case emailLoginButtonTapped
        case newSignUpTapped
        case signUpFeature(PresentationAction<SignUpFeature.Action>)
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:
                
                return .none
            case .kakaoLoginButtonTapped:
                
                if(UserApi.isKakaoTalkLoginAvailable()) {
                    
                    UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                        print(oauthToken)
                        print(error)
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        print(oauthToken)
                        print(error)
                    }
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
                }
            }
                .ifLet(\.$signUp, action: \.signUpFeature) {
                    SignUpFeature()
                }
        }
    }
    
    
    
