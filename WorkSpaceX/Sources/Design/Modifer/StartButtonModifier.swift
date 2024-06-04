//
//  StartButton.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct StartButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(WSXColor.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom)
            .padding(.horizontal)
            .foregroundStyle(WSXColor.white)
            .font(WSXFont.title2)
    }
}
