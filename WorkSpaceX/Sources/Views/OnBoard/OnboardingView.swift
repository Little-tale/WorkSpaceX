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
            .alert(item: $store.loginFail) { _ in
                Text("에러")
            } actions: { _ in
            } message: { text in
                Text(text)
            }

        }
    }
}
