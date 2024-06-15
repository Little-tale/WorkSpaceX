//
//  WorkSpaceTabView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceTabView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceTabCoordinator>

    
    var body: some View {
        
        WithPerceptionTracking {
            ZStack {
                if store.state.ifNoneSpace {
                    NavigationStack {
                        WorkSpaceEmptyListView(
                            store: store.scope(
                                state: \.makeSpaceViewState,
                                action: \.ifNeedMakeWorkSpace
                            )
                        )
                    }
                } else {
                    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                        
                        WorkSpaceListCoordinatorView(
                            store: store.scope(
                                state: \.homeState, action: \.homeTabbar)
                        )
                        /*
                         WorkSpaceListView(
                             store: store.scope(state: \.homeState, action: \.homeTabbar)
                         )
                         */
                        EmptyView()
                        .tag(WorkSpaceTabCoordinator.Tab.home)
                        .tabItem {
                            WSXImage.homeImage.renderingMode(.template)
                            Text(WorkSpaceTabCoordinator.Tab.home.title)
                        }
                        
                        //                            Text("DM")
                        //                                .tabItem {
                        //                                    Text(WorkSpaceXTabFeature.Tab.dm.title) }.tag(WorkSpaceXTabFeature.Tab.dm)
                        //
                        //                            Text("search")
                        //                                .tabItem {
                        //                                    Text(WorkSpaceXTabFeature.Tab.search.title) }.tag(WorkSpaceXTabFeature.Tab.search)
                        //
                        //                            Text("setting")
                        //                                .tabItem {
                        //                                    Text(WorkSpaceXTabFeature.Tab.setting.title) }.tag(WorkSpaceXTabFeature.Tab.setting)
                        
                    }
                    .tint(WSXColor.black)
                    
                }
                SideMenu()
            }
            .onAppear {
                print("????? 왜? ")
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            
        }
    }
    
    
    private func SideMenu() -> some View {
        SideMenuView(isShowing: $store.sideMenuOpen.sending(\.sideMenuMake), direction: .leading) {
            IfLetStore(store.scope(state: \.sideMenuState, action: \.sidebar)) { store in
                WorkSpaceSideView(store: store)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
            }
        }
    }
}

//#Preview {
//    WorkSpaceTabView(store: Store(initialState: { WorkSpaceXTabFeature.State()}(), reducer: {
//        WorkSpaceXTabFeature()
//    }))
//}
