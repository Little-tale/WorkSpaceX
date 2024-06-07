//
//  PopUpViewSmall.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import SwiftUI

struct PopUpViewSmall: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 10)
            .frame(height: 40)
            .foregroundColor(WSXColor.white)
            .font(WSXFont.bodyBold)
            .background(WSXColor.errorRed)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
