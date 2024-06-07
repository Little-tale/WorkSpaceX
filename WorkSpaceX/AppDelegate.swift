//
//  AppDelegate.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import SwiftUI
import UserNotifications
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        KakaoSDK.initSDK(appKey: APIKey.kakaoAPIKey)
        
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("사용자가 거부하심")
                self.showNotificationAllowedAlert()
            }
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (AuthApi.isKakaoTalkLoginUrl(url)){
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 디바이스 토큰 수신 성공시
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

extension AppDelegate {
    
    private func showNotificationAllowedAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        let alert = UIAlertController(
            title: "알림설정 해제 상태",
            message: "알림 설정을 해제 하시면 채팅 알림을 받으 실수 없습니다.\n알림설정 (설정 > 알림 설정)",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "설정 이동", style: .default) { [weak self] _ in
            self?.goSetting()
        }
        let cancel = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        alert.addAction(cancel)
        
        rootViewController.present(alert, animated: true)
    }
    
    private func goSetting() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        }
    }
}
