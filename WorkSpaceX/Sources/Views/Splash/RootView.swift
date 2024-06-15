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
            ZStack {
                
                switch store.currentLoginState {
                case .firstLogin:
                    
                    IfLetStore(store.scope(state: \.workWpaceFirstViewState, action: \.sendToWorkSpaceStart)) { store in
                        WorkSpaceFirstStartView(store: store)
                    }
                case .login:
                        
                    IfLetStore(store.scope(state: \.workSpaceTabViewState, action: \.sendToWorkSpaceTab)) { store in
                        WorkSpaceTabView(store: store)
                    }

                case .logout:
                    
                    IfLetStore(store.scope(state: \.OnboardingViewState, action: \.sendToOnboardingView)) { store in
                        OnboardingView(store: store)
                    }
                }
            }
            .onAppear {
                print("감시중")
                NotificationCenter.default.addObserver(
                    forName: .refreshTokenDead,
                    object: nil,
                    queue: .main) {  _ in
                        store.send(.alert(.presented(.refreshTokkenDead)))
                    }
                store.send(.onAppear)
            }
            .onDisappear {
                print("감시해제")
                NotificationCenter.default.removeObserver(self, name: .refreshTokenDead, object: nil)
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
//                    IfLetStore(store.scope(state: \.workSpaceTabViewState, action: \.sendToWorkSpaceTab)) { store in
//                        WorkSpaceListCoordinatorView(store: store)
//                    }
//                    EmptyView()
//                    WorkSpaceListCoordinatorView(store: store.scope(state: \.workSpaceTabViewState, action: \.sendToWorkSpaceTab))
//                    WorkSpaceListCoordinatorView(store: Store(initialState: .initialState, reducer: {
//                        WorkSpaceTabCoordinator()
//                    }))



//                    WorkSpaceTabView(
//                        store: Store(
//                            initialState: .initialState,
//                            reducer: {
//                                WorkSpaceTabCoordinator()
//                            }
//                        ))
//                    WorkSpaceTabView(store: Store(initialState: WorkSpaceTabCoordinator.State(), reducer: {
//                        WorkSpaceTabCoordinator()
//                    }))
//                    EmptyView()

/*
 if let store = store.scope(state: \.workWpaceFirstViewState, action: \.sendToWorkSpaceStart) {
     WorkSpaceFirstStartView(store: store)
 } else {
     ProgressView()
 }
 
 if let store = store.scope(state: \.OnboardingViewState, action: \.sendToOnboardingView) {
     OnboardingView(store: store)
 } else {
     ProgressView()
 }
 */
