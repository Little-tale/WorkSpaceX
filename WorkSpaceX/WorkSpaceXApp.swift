//
//  WorkSpaceXApp.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

@main
struct WorkSpaceXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
    }
}
