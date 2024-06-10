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
}
