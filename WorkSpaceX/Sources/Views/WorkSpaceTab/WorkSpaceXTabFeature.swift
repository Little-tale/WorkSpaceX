//
//  WorkSpaceXTabFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer
struct WorkSpaceTabCoordinator {
    
    enum Tab: Hashable {
        case home, dm, search, setting
        
        var title: String {
            return switch self {
            case .home:
                "홈"
            case .dm:
                "DM"
            case .search:
                "검색"
            case .setting:
                "설정"
            }
        }
    }
    
    @ObservableState
    struct State: Equatable {
        
        static let initalState = State(
            selectedTab: .home,
            homeState: .initialState
        )
        
        var selectedTab: Tab
        // sidebar State

        
        // HOME STATE
        var homeState: WorkSpaceListCordinator.State
        
        
        var ifNoneSpace = true
        
        var sideMenuOpen = false
        
        // 만약 워크 스페이스가 없을시
        var makeSpaceViewState = WorkSpaceEmptyListFeature.State()
        
        @Presents var alert: AlertState<Action.Alert>?
        
        var sideMenuState: SideMenuCoordinator.State?
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case sidebar(WorkSpaceSideFeature.Action)
        case homeTabbar(WorkSpaceListCordinator.Action)
        
        case tabSelected(Tab)
        case onAppear
        
        case ifNeedMakeWorkSpace(WorkSpaceEmptyListFeature.Action)
        case saveRealmOfProfile(UserEntity)
        case saveRealmOfWorkSpaces([WorkSpaceEntity])
        
        case showEmptyView(Bool)
        
        @CasePathable
        enum Alert {
            case refreshTokkenDead
        }
        case alert(PresentationAction<Alert>)
        
        case sideMenuCoordiAction(SideMenuCoordinator.Action)
        case sideMenuMake(Bool)
    
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.userDomainRepository) var userDominRepo
    @Dependency(\.realmRepository) var realmeRepo
    
    
    var body: some ReducerOf<Self> {
//        BindingReducer()
        
        /// 워크 스페이스가 없을시
        Scope(state: \.makeSpaceViewState, action: \.ifNeedMakeWorkSpace) {
            WorkSpaceEmptyListFeature()
        }
        
        //        // 홈 탭바의 스태이트
        Scope(state: \.homeState, action: \.homeTabbar) {
            WorkSpaceListCordinator()
        }
        
        
        Reduce { state, action in
            switch action {
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                
            case .ifNeedMakeWorkSpace(.openSideMenu):
                return .run { send in
                    await send(.sideMenuMake(true))
                }
                
            case let .sideMenuMake(bool):
                if bool {
                    state.sideMenuState = .selfInit
                } else { state.sideMenuState = nil }
                state.sideMenuOpen = bool

                
            case .onAppear:
                print("????? 왜? 2")
                return .run { send in
                    let result = try await workSpaceRepo.findMyWordSpace()
                    
                    print("현재 스페이스 갯수")
                    dump(result)
                    await send(.saveRealmOfWorkSpaces(result))
                    
                    let profile = try await userDominRepo.myProfile()
                    await send(.saveRealmOfProfile(profile))
                    print("프로필 조회임~ ",profile)
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceMeError {
                        
                        if error.ifDevelopError {
                            print(error.message)
                        } else {
                            print(error)
                        }
                    } else if let error = error as? MyProfileAPIError {
                        
                        if let error = error.ifCommonError {
                            print("프로필 조회 에러",error)
                        }
                    } else {
                        print("별개의 에러",error)
                    }
                }
                
            case let .saveRealmOfProfile(user):
                realmeRepo.upsertUserModel(response: user)
                return .none
                
            case let .saveRealmOfWorkSpaces(workSpaces):
                realmeRepo.upsertWorkSpaces(responses: workSpaces)
                if workSpaces.isEmpty {
                    return .run { send in
                        await send(.showEmptyView(true))
                    }
                }
                return .none
                
            case let .showEmptyView(bool):
                state.ifNoneSpace = bool
                return .none
                
            case .sideMenuCoordiAction(.backOff):
                return .run{ send in
                    await send(.sideMenuMake(false))
                }
            
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.sideMenuState, action: \.sideMenuCoordiAction) {
            SideMenuCoordinator()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}


//@Reducer
//struct WorkSpaceXTabFeature {
//
//    enum Tab: Equatable {
//        case home, dm, search, setting
//
//        var title: String {
//            return switch self {
//            case .home:
//                "홈"
//            case .dm:
//                "DM"
//            case .search:
//                "검색"
//            case .setting:
//                "설정"
//            }
//        }
//    }
//    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
//    @Dependency(\.userDomainRepository) var userDominRepo
//
//    @Dependency(\.realmRepository) var realmeRepo
//
//    @ObservableState
//    struct State: Equatable {
//        var currentTab = Tab.home
//        // sidebar State
//        var sidebarState = WorkSpaceSideFeature.State()
//
//        // 만약 워크 스페이스가 없을시
//        var makeSpaceViewState = WorkSpaceEmptyListFeature.State()
//        var homeState = WorkSpaceListFeature.State()
//        var ifNoneSpace = true
//        @Presents var alert: AlertState<Action.Alert>?
//        var sideMenuOpen = false
//    }
//
//    enum Action {
//        case homeAction(WorkSpaceListFeature.Action)
//        case selectedTab(Tab)
//        case ifNeedMakeWorkSpace(WorkSpaceEmptyListFeature.Action)
//        case sideMenuAction(WorkSpaceSideFeature.Action)
//
//        case appear
//        case refreshDead
//
//        enum Delegate {
//            case checkRootView
//            case currentSpaces([WorkSpaceEntity])
//            case refreshDead
//            case profile(UserEntity)
//        }
//        case delegate(Delegate)
//
//        @CasePathable
//        enum Alert {
//            case refreshTokkenDead
//        }
//        case alert(PresentationAction<Alert>)
//        case showSideMenu(Bool)
//
//    }
//
//    var body: some ReducerOf<Self> {
//
//
//        Scope(state: \.makeSpaceViewState, action: \.ifNeedMakeWorkSpace) {
//            WorkSpaceEmptyListFeature()
//        }
//
//        // 사이드 바 스테이트
//        Scope(state: \.sidebarState, action: \.sideMenuAction) {
//            WorkSpaceSideFeature()
//        }
//
//        Scope(state: \.homeState, action: \.homeAction) {
//            WorkSpaceListFeature()
//        }
//
//
//        Reduce { state, action in
//            switch action {
//            case .alert(.presented(.refreshTokkenDead)):
//
//                return .run{ send in
//                    await send(.delegate(.checkRootView))
//                }
//
//            case .alert(.dismiss):
//                return .none
//
//            case .selectedTab(let tab):
//                state.currentTab = tab
//                return .none
//
//                // 워크 스페이스 Empty 영역
//            case .ifNeedMakeWorkSpace(.openSideMenu):
//
//                return .run { send in
//                    await send(.showSideMenu(true))
//                }
//
//            case .ifNeedMakeWorkSpace:
//
//                return .none
//            case .sideMenuAction:
//
//                return .none
//
//            case .appear:
//
//                return .run { send in
//                    let result = try await workSpaceRepo.findMyWordSpace()
//                    print("현재 스페이스 갯수")
//                    dump(result)
//                    await send(.delegate(.currentSpaces(result)))
//
//                    let profile = try await userDominRepo.myProfile()
//                    await send(.delegate(.profile(profile)))
//
//                    print("프로필 조회임~ ",profile)
//
//                } catch: { error, send in
//                    if let error = error as? WorkSpaceMeError {
//                        if error.ifReFreshDead {
//                            print(error)
//                            await send(.refreshDead)
//                        }
//                        if error.ifDevelopError {
//                            print(error.message)
//                        } else {
//                            print(error)
//                        }
//                    } else if let error = error as? MyProfileAPIError {
//                        if error.ifReFreshDead {
//                            print(error)
//                            await send(.refreshDead)
//                        }
//                        if let error = error.ifCommonError {
//                            print("프로필 조회 에러",error)
//                        }
//                    } else {
//                        print("별개의 에러",error)
//                    }
//                }
//
//            case .refreshDead:
//                state.alert = .refreshDeadAlert
//                return .none
//
//            case .delegate(.profile(let model)):
//
//                realmeRepo.upsertUserModel(response: model)
//
//                return .none
//            case .delegate:
//
//                return .none
//            case let .showSideMenu(bool):
//                state.sideMenuOpen = bool
//                return .none
//
//            }
//        }
//        .ifLet(\.$alert, action: \.alert)
//
//    }
//
//}


//extension AlertState where Action == WorkSpaceXTabFeature.Action.Alert {
//
//    static let refreshDeadAlert = Self {
//        TextState("재 로그인 필요")
//    } actions: {
//        ButtonState(role: .destructive, action: .refreshTokkenDead) {
//            TextState("확인")
//        }
//    } message: {
//        TextState("로그인 시간이 만료되어 재로그인이 필요합니다 ㅠㅠ")
//    }
//
//}


extension AlertState where Action == RootFeature.Action.Alert {
    
    static let refreshDeadAlert = Self {
        TextState("재 로그인 필요")
    } actions: {
        ButtonState(role: .destructive, action: .refreshTokkenDead) {
            TextState("확인")
        }
    } message: {
        TextState("로그인 시간이 만료되어 재로그인이 필요합니다 ㅠㅠ")
    }
}
