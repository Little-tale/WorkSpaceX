//
//  BottomToastColorVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/5/24.
//

import Foundation

import SwiftUI

struct StaticToastColorView: View {
    
    @State private var isVisible: Bool = false
    @State private var timer: Timer?
    
    @Binding
    var text: String?
    
    let color: Color
    let duration: Double
    
    var body: some View {
        Group {
            if let text {
                Text(text)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .foregroundColor(WSXColor.white)
                    .font(WSXFont.bodyBold)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onAppear {
                        startTimer()
                    }
            } else {
                EmptyView()
                    .onAppear {
                        timer?.invalidate()
                    }
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation {
                isVisible = false
                text = nil
            }
        }
    }
}

/*
 // 작동 하지만 라이브러리로도 구현 해보기.
 private func ifCurrectView(text: String?) -> some View {
     // 각 버튼별로 로직이 다름을 생각해야함.
     // 이친구는 Text를 받아야 할것 같음
     withAnimation {
         Group {
             if let text {
                 Text(text)
                     .padding(.horizontal, 10)
                     .frame(height: 40)
                     .foregroundStyle(WSXColor.white)
                     .font(WSXFont.bodyBold)
                     .background(WSXColor.green)
                     .clipShape(RoundedRectangle(cornerRadius: 12))
             } else {
                 EmptyView()
             }
         }
     }
 }
 */
