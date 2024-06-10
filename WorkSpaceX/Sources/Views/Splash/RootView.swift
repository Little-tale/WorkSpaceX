//
//  RootView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    
    @Perception.Bindable var store = Store(
        initialState: RootFeature.State()) {
            RootFeature()
        }
    
    var body: some View {
        Text("")
            .onAppear {
                
            }
    }
}
/*
 switch store.currentLoginState {
 case .firstLogin:
     
 case .login:
     
 case .logout:
     
 }
 
 store = Store(initialState: OnboardingFeature.State()) {
     OnboardingFeature()
 }
 */
