//
//  NormalButtonViewModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import SwiftUI

struct NormalButtonViewModifier: ViewModifier {
    
    enum ColorSet {
        case red
        case def
        case custom(Color)
        
        var exitColor: Color {
            switch self {
            case .red:
                return WSXColor.errorRed
            case .def:
                return WSXColor.black
            case .custom(let color):
                return color
            }
        }
    }
    
    let colorSetting: ColorSet
    
    var tapped: () -> Void
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(WSXColor.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(colorSetting.exitColor)
            )
            .asButton {
                tapped()
            }
            .padding(.horizontal, 24)
            .foregroundStyle(colorSetting.exitColor)
    }
    
}
