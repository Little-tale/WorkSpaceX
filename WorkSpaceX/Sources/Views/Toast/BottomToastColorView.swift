//
//  BottomToastColorVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/5/24.
//

import Foundation

import SwiftUI

struct BottomToastColorView: View {
    
    let text: String?
    let Color: Color
    
    var body: some View {
        Group {
            if let text {
                Text(text)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .foregroundStyle(WSXColor.white)
                    .font(WSXFont.bodyBold)
                    .background(Color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyView()
            }
        }
    }
}
