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
                        NavigationStack {
                            SignUpView(store: store)
                                .presentationDragIndicator(.visible)
                                .navigationTitle(
                                    Text("회원가입")
                                )
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .font(WSXFont.title2)
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
                            NavigationStack {
                                EmailLoginView(store: store)
                                    .presentationDragIndicator(.visible)
                                    .navigationTitle(
                                        Text("이메일 로그인")
                                    )
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                            .font(WSXFont.title2)
                        }
        }
        
    }
    
}


extension OnboardingLoginView {
    
    private func contentView() -> some View {
        VStack (alignment: .center, spacing: 13) {
            
            WSXImage.appleLogin
                .modifier(CommonButtonModifer())
                .asButton {
                    store.send(.appleLoginButtonTapped)
                }
            
            WSXImage.kakaoLogin
                .modifier(CommonButtonModifer())
                .asButton {
                    store.send(.kakaoLoginButtonTapped)
                }
            
            WSXImage.emailLoginButton
                .modifier(CommonButtonModifer())
                .asButton {
                    store.send(.emailLoginButtonTapped)
                }
            HStack {
                Text("또는")
                
                Text("새롭게 회원가입 하기")
                    .foregroundStyle(WSXColor.lightGreen)
                    .asButton {
                        store.send(.newSignUpTapped)
                    }
                
            }
        }
    }
    
}
