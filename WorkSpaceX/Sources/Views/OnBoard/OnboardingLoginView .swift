//
//  OnboardingLoginView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct OnboardingLoginView: View {
    
    var body: some View {
        VStack (spacing: 13) {
            
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
        }
    }
    
    
}

#Preview {
    OnboardingLoginView()
}
