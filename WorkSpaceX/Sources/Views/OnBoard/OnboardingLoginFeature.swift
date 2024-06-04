//
//  OnboardingLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture

@Reducer
struct OnboardingLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp: SignUpFreature.State?
        
    }
    
    @Dependency(\.dismiss) var dismiss
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        case emailLoginButtonTapped
        case newSignUpTapped
        case signUpFeature(PresentationAction<SignUpFreature.Action>)
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:
                
                return .none
            case .kakaoLoginButtonTapped:
                
                return .none
            case .emailLoginButtonTapped:
                
                return .none
                
            case .newSignUpTapped:
                state.signUp = SignUpFreature.State()
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
            SignUpFreature()
        }
    }
}



