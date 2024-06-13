//
//  WSXColor.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

enum WSXColor {}

extension WSXColor {
    
    static let green = Color(ColorResource.wsxGreen)
    
    static let lightGreen = Color(ColorResource.lightGreen)
    
    static let errorRed = Color(ColorResource.errorRed)
    
    static let inacitve = Color(ColorResource.inactive)
    
    static let black = Color(ColorResource.wsxBlack)
    
    static let white = Color(ColorResource.wsxWhite)
    
    static let gray = Color(ColorResource.wsxGray)
    
    
    static let lightGray = Color(ColorResource.onlyLightGrey)
    
    
    static let titleGradient = LinearGradient(
        colors: [.red, .blue, .green, .yellow],
        startPoint: .leading,
        endPoint: .trailing
    )
}
