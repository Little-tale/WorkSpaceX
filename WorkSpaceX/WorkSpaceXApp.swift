//
//  WorkSpaceXApp.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import ComposableArchitecture

@main
struct WorkSpaceXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
            RootView(store: Store(
                initialState: RootFeature.State()) {
                    RootFeature()
                })
            .onOpenURL { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)){
                    _ = AuthController.handleOpenUrl(url: url)
                }
            }
        }
        
    }
}
