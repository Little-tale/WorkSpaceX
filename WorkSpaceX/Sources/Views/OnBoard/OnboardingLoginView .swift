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
            VStack (alignment: .center, spacing: 13) {
                
                WSXImage.appleLogin
                    .modifier(CommonButtonModifer())
                    .asButton {
                        
                    }
                
                WSXImage.kakaoLogin
                    .modifier(CommonButtonModifer())
                    .asButton {
                        
                    }
                
                WSXImage.emailLoginButton
                    .modifier(CommonButtonModifer())
                    .asButton {
                        
                    }
                HStack {
                    Text("또는")
                    
                    Text("새롭게 회원가입 하기")
                        .foregroundStyle(WSXColor.lightGreen)
                        .asButton {
                            store.send(.newSignUpTapped)
                        }
                }
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
                }
                .font(WSXFont.title2)
            }
        }
        
    }
    
}

