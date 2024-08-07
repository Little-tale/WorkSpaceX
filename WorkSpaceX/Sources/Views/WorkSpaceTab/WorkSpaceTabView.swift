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
                    tabView()
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
            .alert(store.refreshAlertText.title,
                   isPresented: $store.refreshAlert) {
                Text(store.refreshAlertText.action)
                    .asButton {
                        store.send(.refreshChecked)
                    }
            } message: {
                Text(store.refreshAlertText.maeesage)
            }
        }
    }
}


extension WorkSpaceTabView {
    
    private func tabView() -> some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            /// 홈뷰
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
            /// DM뷰
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
            /// 검색뷰
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
            /// 설정뷰
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
        }
        .tint(WSXColor.black)
       
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

