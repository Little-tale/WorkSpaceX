//
//  OnboardingVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    
    @Perception.Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack (alignment: .bottom) {
                SplashView()
                Text(Const.SplashView.startText)
                    .modifier(StartButtonModifier())
                    .asButton {
                        store.send(.startButtonTapped)
                    }
                    .buttonStyle(PlainButtonStyle())
                
            }
            .sheet(item: $store.scope(state: \.onboard, action: \.onboardingLoginFeature)) { store in
                OnboardingLoginView(store: store)
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
                
            }
        }
    }
    
    init() {
        store = Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    }
}

#Preview {
    OnboardingView()
}
