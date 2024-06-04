//
//  OnboardingLoginView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct OnboardingLoginView: View {
    
    
    var body: some View {
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
            }
            .font(WSXFont.title2)
        }
    }
    
}

#Preview {
    OnboardingLoginView()
}
