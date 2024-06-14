//
//  ExView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import SwiftUI

extension View {
    func goSetting() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        }
    }
    
    var keyboardPadding: CGFloat {
        let keyboardFrame = UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?.keyboardLayoutGuide.layoutFrame.height ?? 0
        return keyboardFrame
    }
    
    func centerOverlay(size: CGSize) -> some View {
        self
            .frame(width: size.width, height: size.height)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                self
                    .frame(width: size.width, height: size.height)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding()
                    .centered()
            )
    }
    func centered() -> some View {
        GeometryReader { geometry in
            self
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    func sideOverlay() -> some View {
        
        GeometryReader { geometry in
            self
                .frame(width: geometry.size.width / 2)
        }
        
    }
}
