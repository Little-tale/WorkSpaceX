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
    }
    
    enum Action {
        case startButtonTapped
        case onboardingLoginFeature(PresentationAction<OnboardingLoginFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
               
                state.onboard = OnboardingLoginFeature.State()
                // 뭐가 있을거임.
                return .none
                
            case .onboardingLoginFeature:
                
                return .none
            }
        }
        .ifLet(\.$onboard, action:\.onboardingLoginFeature) {
            OnboardingLoginFeature()
        }
    }
}