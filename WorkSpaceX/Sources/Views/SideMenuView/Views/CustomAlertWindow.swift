//
//  CustomAlertWindow.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/17/24.
//

import SwiftUI
/*
 회고
 */
final class CustomAlertWindow {
    static let shared = CustomAlertWindow()
    private var window: UIWindow?
    
    func show<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        if let windowSceen = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowSceen)
            
            let hostingController = UIHostingController(rootView: content())
            
            hostingController.view.backgroundColor = .clear
            
            window.rootViewController = hostingController
            window.windowLevel = .alert + 1
            window.makeKeyAndVisible()
            self.window = window
            
            hostingController.view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                hostingController.view.alpha = 1
            }
        }
    }
    
    func hide() {
        self.window?.isHidden = true
    
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            window?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else {
                self?.window = nil
                return
            }
            window = nil
        }
    }
}
