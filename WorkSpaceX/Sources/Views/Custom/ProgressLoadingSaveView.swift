//
//  ProgressLoadingSaveView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/7/24.
//

import SwiftUI

struct ProgressLoadingSaveView: View {
    var body: some View {
        VStack {
            Text("수정중...")
                .font(WSXFont.bigTitle3)
            Text("잠시만 기달려 주세요!")
                .font(WSXFont.title1)
                .padding(.bottom, 4)
            ProgressView()
                .frame(width: 70, height: 70)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(WSXColor.white)
        .foregroundStyle(WSXColor.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
}
