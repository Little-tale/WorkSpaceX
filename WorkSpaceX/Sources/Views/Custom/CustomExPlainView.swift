//
//  CustomExPlainView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI

struct ExplainState: Equatable {
    let title = "코인이란?"
    
    let explain = """
코인은 워크스페이스 생성 시 사용되요!
모두 소진 된다면 더이상
워크 스페이스를 생성 하실수 없어요!
"""
    
    let actionTitle = "확인했어요!"
}

struct CustomExPlainView: View {
    
    let item: ExplainState
    
    var close: () -> Void
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            WSXImage.Coin.big
                .image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
            
            Text(item.title)
                .foregroundStyle(WSXColor.black)
                .font(WSXFont.title0)
                .padding(.top, 12)
            
            Text(item.explain)
                .foregroundStyle(WSXColor.black)
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Text(item.actionTitle)
                .font(WSXFont.title1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 22)
                .foregroundStyle(WSXColor.white)
                .background(WSXColor.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .asButton {
                    close()
                }
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(
            WSXColor.white
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadowedStyle()
        .padding(.horizontal, 40)
    }
}
