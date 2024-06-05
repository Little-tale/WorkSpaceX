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
            if let text, isVisible {
                Text(text)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .foregroundColor(WSXColor.white)
                    .font(WSXFont.bodyBold)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onAppear {
                        print("....isVisible \(isVisible)")
                        startTimer()
                    }
            } else {
                EmptyView()
            }
        }
        .onChange(of: text) { newValue in
            if newValue != nil {
                isVisible = true
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        // isVisible = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation {
                isVisible = true
                text = nil
            }
        }
    }
}


