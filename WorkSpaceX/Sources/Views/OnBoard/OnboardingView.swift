//
//  OnboardingVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct OnboardingView: View {
    
    
    
    var body: some View {
        ZStack (alignment: .bottom) {
            SplashView()
            Text("시작하기")
                .modifier(StartButtonModifier())
                .asButton {
                    print("클릭")
                }
                .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    OnboardingView()
}
