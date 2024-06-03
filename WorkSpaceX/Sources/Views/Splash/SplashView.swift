//
//  SplashView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct SplashView: View {
    
    // 회원인경우:  Home 에서 시작
    // 아닐 경우: Onboarding에서 시작
    
    var body: some View {
        VStack {
            Spacer()
            WSCImage.rootViewImage
                .aspectRatio(0.9, contentMode: .fit)
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            
            Text(Const.SplashView.bennerTitel)
                .multilineTextAlignment(.center)
                .font(WSCFont.title1)
            
            Spacer()
        }
        
    }

}


#Preview {
    SplashView()
}
