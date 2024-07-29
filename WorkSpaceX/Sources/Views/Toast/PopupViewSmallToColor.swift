//
//  PopupViewSmallToColor.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import SwiftUI

struct PopupViewSmallToColor: View {
    
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 10)
            .frame(height: 40)
            .foregroundColor(WSXColor.white)
            .font(WSXFont.bodyBold)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
