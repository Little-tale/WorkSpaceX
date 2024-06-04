//
//  defaultTextFieldViewModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

struct DefaultTextFieldViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.leading, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(WSXColor.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
