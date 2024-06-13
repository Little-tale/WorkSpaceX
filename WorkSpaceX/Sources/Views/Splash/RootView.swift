//
//  RootView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.currentLoginState {
                case .firstLogin:
                    if let store = store.scope(state: \.workWpaceFirstViewState, action: \.sendToWorkSpaceStart) {
                        WorkSpaceFirstStartView(store: store)
                    } else {
                        ProgressView()
                    }
                case .login:
                    IfLetStore(store.scope(state: \.workSpaceTabViewState, action: \.sendToWorkSpaceTab)) { store in
                        WorkSpaceTabView(store: store)
                    }
                case .logout:
                    if let store = store.scope(state: \.OnboardingViewState, action: \.sendToOnboardingView) {
                        OnboardingView(store: store)
                    } else {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
                NotificationCenter.default.addObserver(
                    forName: .ifNeedReChack,
                    object: nil,
                    queue: .main) { _ in
                        print("한번씩만...")
                        store.send(.onAppear)
                    }
            }
        }
    }
}
/*
 Store(initialState: WorkSpaceFirstStartFeature.State()) {
     WorkSpaceFirstStartFeature()
 }
 
 store = Store(initialState: OnboardingFeature.State()) {
     OnboardingFeature()
 }
 */
