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
        
    }
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        case emailLoginButtonTapped
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
            }
        }
    }
}



