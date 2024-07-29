//
//  OnboardingLoginView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingLoginView: View {
    
    @Perception.Bindable var store: StoreOf<OnboardingLoginFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            
            contentView()
                .sheet(
                    item: $store.scope(
                        state: \.signUp,
                        action: \.signUpFeature
                    )) { store in
                        SignUpView(store: store)
                    }
                    .alert(item: $store.errorPresentation.sending(\.errorMessage)) { _ in
                        Text("에러")
                    } actions: { _ in
                    } message: { message in
                        Text(message)
                    }
                    .sheet(
                        item: $store.scope(
                            state: \.emailLogin,
                            action: \.emailLoginFeature
                        )) { store in
                            EmailLoginView(store: store)
                        }
        }
        
    }
    
}


extension OnboardingLoginView {
    
    private func contentView() -> some View {
        VStack (alignment: .center, spacing: 13) {
            
            WSXImage.appleLogin
                .modifier(CommonButtonModifier())
                .asButton {
                    store.send(.appleLoginButtonTapped)
                }
            
            WSXImage.kakaoLogin
                .modifier(CommonButtonModifier())
                .asButton {
                    store.send(.kakaoLoginButtonTapped)
                }
            
            WSXImage.emailLoginButton
                .modifier(CommonButtonModifier())
                .asButton {
                    store.send(.emailLoginButtonTapped)
                }
            HStack {
                Text(store.viewText.also)
                
                Text(store.viewText.newUser)
                    .foregroundStyle(WSXColor.lightGreen)
                    .asButton {
                        store.send(.newSignUpTapped)
                    }
                
            }
        }
    }
    
}
