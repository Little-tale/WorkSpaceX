//
//  WSXImage.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

enum WSXImage {}

extension WSXImage {
    static let splashImage: Image = Image(.rootView).resizable()
    
    static let appleLogin: Image = Image(.applLoginButton).resizable()
    
    static let kakaoLogin: Image =  Image(.kakaoLoginButton).resizable()
        
    static let emailLoginButton: Image = Image(.emailLoginButton).resizable()
    
    static let xImage: Image = Image(systemName: "xmark").resizable().renderingMode(.template)
    
    static let logoImage: Image = Image(.workSpaceXLogo)
}
