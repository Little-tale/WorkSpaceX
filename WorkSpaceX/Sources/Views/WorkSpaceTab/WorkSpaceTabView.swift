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
                switch store.state.ifNoneSpace {
                case .loading:
                    ProgressView()
                case .noneSpace:
                    NavigationStack {
                        WorkSpaceEmptyListView(
                            store: store.scope(
                                state: \.makeSpaceViewState,
                                action: \.ifNeedMakeWorkSpace
                            )
                        )
                    }
                case .notEmpty:
                    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                        
                        WorkSpaceListCoordinatorView(
                            store: store.scope(
                                state: \.homeState, action: \.homeTabbar)
                        )
                        .tag(WorkSpaceTabCoordinator.Tab.home)
                        .tabItem {
                            VStack {
                                WSXImage.homeImage
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(WorkSpaceTabCoordinator.Tab.home.title)
                            }
                        }
                        
                        DMSCoordinatorView(store: store.scope(state: \.dmHomeState, action: \.dmsTabbar))
                            .tag(WorkSpaceTabCoordinator.Tab.dm)
                            .tabItem {
                                VStack {
                                    WSXImage.dmsTab
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text(WorkSpaceTabCoordinator.Tab.dm.title)
                                }
                            }
                        
                        SearchCoordinatorView(store: store.scope(state: \.searchState, action: \.searchTabbar))
                            .tag(WorkSpaceTabCoordinator.Tab.search)
                            .tabItem {
                                VStack {
                                    WSXImage.searchImage
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text(WorkSpaceTabCoordinator.Tab.search.title)
                                }
                            }
                        SettingCoordinatorView(store: store.scope(state: \.settingState, action: \.settingTabbar))
                            .tag(WorkSpaceTabCoordinator.Tab.setting)
                            .tabItem {
                                VStack {
                                    WSXImage.settingImage
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text(WorkSpaceTabCoordinator.Tab.setting.title)
                                }
                            }
                        //                            Text("setting")
                        //                                .tabItem {
                        //                                    Text(WorkSpaceXTabFeature.Tab.setting.title) }.tag(WorkSpaceXTabFeature.Tab.setting)
                        
                    }
                    .tint(WSXColor.black)
                }
                SideMenu()
            }
            .sheet(item: $store.scope(state: \.makeWorkSpaceState, action: \.sendWorkSpaceMakeAction)) { store in
                WorkSpaceInitalView(store: store)
            }
            .onAppear {
                print("감시중")
                NotificationCenter.default.addObserver(
                    forName: .refreshTokenDead,
                    object: nil,
                    queue: .main) {  _ in
                        store.send(.refreshDeadAlert(true))
                    }
                store.send(.onAppear)
            }
            .onDisappear {
                print("감시해제")
                NotificationCenter.default.removeObserver(self, name: .refreshTokenDead, object: nil)
            }
            .alert("재로그인 필요",
                   isPresented: $store.refreshAlert) {
                Text("확인")
                    .asButton {
                        store.send(.refreshChecked)
                    }
            } message: {
                Text("로그인 정보가 만료되어 재로그인이 필요합니다.")
            }

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
