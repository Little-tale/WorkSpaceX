//
//  WorkSpaceXTabFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
/*
 유저 디폴트도 삭제 되었을때 반영 시켜놓아야 함....
 */

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
        static let homeCoordiID = UUID()
        
        static let initalState = State(
            selectedTab: .home,
            homeState: WorkSpaceListCordinator.State.initialState,
            dmHomeState: DMSCoordinator.State.initialState,
            searchState: SearchCoordinator.State.initialState,
            settingState: SettingCoordinator.State.initialState
        )
        
        var selectedTab: Tab
        // sidebar State
        
        var firstInTrigger = true
        
        // HOME STATE
        var homeState: WorkSpaceListCordinator.State
        // DM State
        var dmHomeState: DMSCoordinator.State
        // searchTab State
        var searchState: SearchCoordinator.State
        // setting State
        var settingState: SettingCoordinator.State
        
        var ifNoneSpace: viewStateCase = .loading
        
        var sideMenuOpen = false
        
        // 만약 워크 스페이스가 없을시
        var makeSpaceViewState = WorkSpaceEmptyListFeature.State()
        
        var sideMenuState: WorkSpaceSideFeature.State?
        
        let refreshAlertText = ReloadAlertText()
        
        // 탭뷰 자체적으로 프레젠테이션 하겠습니다.
        @Presents var makeWorkSpaceState: WorkSpaceInitialFeature.State?
        var currentCount = 0
        var currentModels: [WorkSpaceRealmModel] = []
        
        // Refresh
        var refreshAlert: Bool = false
    }
    
    struct ReloadAlertText: Equatable {
        let title = "재로그인 필요"
        let action = "확인"
        let maeesage = "로그인 정보가 만료되어 재로그인이 필요합니다."
    }
    
    enum viewStateCase {
        case loading
        case noneSpace
        case notEmpty
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case sidebar(WorkSpaceSideFeature.Action)
        
        case homeTabbar(WorkSpaceListCordinator.Action)
        case dmsTabbar(DMSCoordinator.Action)
        case searchTabbar(SearchCoordinator.Action)
        case settingTabbar(SettingCoordinator.Action)
        
        case tabSelected(Tab)
        case onAppear
        
        case ifNeedMakeWorkSpace(WorkSpaceEmptyListFeature.Action)
        case saveRealmOfProfile(UserEntity)
        case saveRealmOfWorkSpaces([WorkSpaceEntity])
        
        case showEmptyView(Bool)
        
        case refreshChecked
        case refreshDeadAlert(Bool)
        // case sideMenuCoordiAction(SideMenuCoordinator.Action)
        case sideMenuMake(Bool)
        
        case sendWorkSpaceMakeAction(PresentationAction<WorkSpaceInitialFeature.Action>)
        case makeWorkSpaceStart(Bool)
        case workSpaceRegSuccess(id: String)
        
        case workSpaceSubscribe
        case currentModelCatch([WorkSpaceRealmModel])
        
        case noWorkSpaceTrigger
        
        case delegate(Delegate)
        
        enum Delegate {
            case moveToOnBoardingView
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.userDomainRepository) var userDominRepo
    @Dependency(\.realmRepository) var realmeRepo
    @Dependency(\.workSpaceReader) var workSpaceReader
//    static let realmRepo = RealmRepository()
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        /// 워크 스페이스가 없을시
        Scope(state: \.makeSpaceViewState, action: \.ifNeedMakeWorkSpace) {
            WorkSpaceEmptyListFeature()
        }
        
        // 홈 탭바의 State
        Scope(state: \.homeState, action: \.homeTabbar) {
            WorkSpaceListCordinator()
        }
        
        // DMS 탭 바의 State
        Scope(state: \.dmHomeState, action: \.dmsTabbar) {
            DMSCoordinator()
        }
        
        // 검색 탭바의 State
        Scope(state: \.searchState, action: \.searchTabbar) {
            SearchCoordinator()
        }
        
        // 세팅 탭바의 스테이트
        Scope(state: \.settingState, action: \.settingTabbar) {
            SettingCoordinator()
        }
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                print("????? 왜? 2")
                return .run { send in
                
                    let profile = try await userDominRepo.myProfile()
               
                    let user = UserEntity(
                        userID: profile.userID,
                        email: profile.email,
                        nickname: profile.nickname,
                        profileImage: profile.profileImage,
                        phone: profile.phone,
                        provider: profile.provider,
                        createdAt: profile.createdAt,
                        token: nil
                    )
                    
                    await send(.saveRealmOfProfile(user))
                    print("프로필 조회임~ ",profile)
                    await send(.workSpaceSubscribe)
                } catch: { error, send in
                   if let error = error as? MyProfileAPIError {
                        if let error = error.ifCommonError {
                            print("프로필 조회 에러",error)
                        }
                       
                    } else {
                        print("별개의 에러",error)
                    }
                }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                
            case .ifNeedMakeWorkSpace(.openSideMenu):
                return .run { send in
                    await send(.sideMenuMake(true))
                }
            case .ifNeedMakeWorkSpace(.regSuccess):
                let id = UserDefaultsManager.workSpaceSelectedID
                print("허허... 에러인가 \(id)")
                return .run { send in
                    await send(.workSpaceSubscribe)
                }
                
            case let .sideMenuMake(bool):
                if bool {
                    state.sideMenuState = WorkSpaceSideFeature.State()
                } else { state.sideMenuState = nil }
                state.sideMenuOpen = bool
                
            case let .saveRealmOfProfile(user):
                
                return .run { send in
                    try await realmeRepo.upsertUserModel(response: user)
                } catch: { error, _ in
                    print(error)
                }
                
            case let .saveRealmOfWorkSpaces(workSpaces):
                return .run { send in
                    try await realmeRepo.upsertWorkSpaces(responses: workSpaces)
                    print("처음 : \(workSpaces.count)")
                    await send(.showEmptyView(workSpaces.isEmpty))
                } catch: { error, _ in
                    print(error)
                }
                
                
            case let .showEmptyView(bool):
                if bool {
                    state.ifNoneSpace = .noneSpace
                } else {
                    state.ifNoneSpace = .notEmpty
                }
                
                return .none
               
            case .sidebar(.sendToMakeWorkSpace):
                
                return .run { send in
                    await send(.sideMenuMake(false))
                    try await Task.sleep(for: .seconds(0.3))
                    await send(.makeWorkSpaceStart(true))
                }
            case .makeWorkSpaceStart(let bool):
                if bool {
                    state.makeWorkSpaceState = WorkSpaceInitialFeature.State()
                } else {
                    state.makeWorkSpaceState = nil
                }
                
            case .sendWorkSpaceMakeAction(.presented(.realmRegSuccess(let id))):
                return .run { send in
                    await send(.workSpaceRegSuccess(id: id))
                    await send(.makeWorkSpaceStart(false))
                }
                
               
            case .sidebar(.goBackToRoot):
                return .run{ send in
                    await send(.sideMenuMake(false))
                }
            case let .sidebar(.selectedModeltoPresent(model)):
                state.sideMenuOpen = false
                print(model)
               
                let workSpaceId = model.workSpaceID
                
                return .run { send in
                    await send(.homeTabbar(.sendToRootWorkSpaceID(workSpaceId)))
                    await send(.dmsTabbar(.parentAction(.getWorkSpaceId(workSpaceId))))
                    
                    await send(.searchTabbar(.parentAction(.sendToWorkSpaceID(workSpaceId))))
                    
                    await send(.settingTabbar(.parentAction(.getWorkSpaceId(workSpaceId))))
                }
                
            case let .sidebar(.delegate(.changedWorkSpaceID(id))):
                PollingManager.shared.stopPolling()
                if let id {
                    return .run { send in
                        await send(.homeTabbar(.sendToRootWorkSpaceID(id)))
                        await send(.dmsTabbar(.parentAction(.getWorkSpaceId(id))))
                        
                        await send(.searchTabbar(.parentAction(.sendToWorkSpaceID(id))))
                        
                        await send(.settingTabbar(.parentAction(.getWorkSpaceId(id))))
                    }
                } else {
                    
//                    return .run { send in
//                        await send(.noWorkSpaceTrigger)
//                    }
                }
                
           
            case .workSpaceRegSuccess(let id):
                UserDefaultsManager.workSpaceSelectedID = id
                
                return .run { send in
                     await send(.homeTabbar(.sendToRootWorkSpaceID(id)))
                    
                    await send(.onAppear)
                    
                    await send(.dmsTabbar(.parentAction(.getWorkSpaceId(id))))
                    await send(.searchTabbar(.parentAction(.sendToWorkSpaceID(id))))
                    await send(.settingTabbar(.parentAction(.getWorkSpaceId(id))))
                }
                
            case let .refreshDeadAlert(bool):
                state.refreshAlert = bool
                return .run { send in
                    try await realmeRepo.logout()
                } catch : { error, _ in print(error) }

            
            case .workSpaceSubscribe:
                
                let workSpaceID = UserDefaultsManager.workSpaceSelectedID
                
                return .run { send in
                    let result = try await workSpaceRepo.findMyWordSpace()
                    
                    await send(.saveRealmOfWorkSpaces(result))
                    
                    if workSpaceID != "" {
                        await send(.homeTabbar(.sendToRootWorkSpaceID(workSpaceID)))
                        await send(.dmsTabbar(.parentAction(.getWorkSpaceId(workSpaceID))))
                        
                        await send(.searchTabbar(.parentAction(.sendToWorkSpaceID(workSpaceID))))
                        
                        await send(.settingTabbar(.parentAction(.getWorkSpaceId(workSpaceID))))
                        
                    } else if let first = result.first {
                        UserDefaultsManager.workSpaceSelectedID
                        = first.workSpaceID
                        await send(.homeTabbar(.sendToRootWorkSpaceID(first.workSpaceID)))
                        await send(.dmsTabbar(.parentAction(.getWorkSpaceId(first.workSpaceID))))
                        await send(.searchTabbar(.parentAction(.sendToWorkSpaceID(first.workSpaceID))))
                        
                        await send(.settingTabbar(.parentAction(.getWorkSpaceId(first.workSpaceID))))
                    }
                    
                    for await models in await workSpaceReader.observeChanges(for: WorkSpaceRealmModel.self, sorted: "createdAt", ascending: true) {
                        await send(.currentModelCatch(models))
                    }
                } catch : { error, send in
                    if let error = error as? WorkSpaceMeError {
                        if !error.ifDevelopError {
                            print(error)
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .currentModelCatch(models):
                let count = models.count
                state.currentCount = count
                
                state.currentModels = models
                
                print("처음 \(count)")
//                if state.firstInTrigger {
//                    state.firstInTrigger = false
//                    
//                }
                return .run{ send in
                    await send(.showEmptyView(count == 0))
                }
            
                // HomeTabDelegte
            case .homeTabbar(.delegate(.openSideMenu)):
                return .send(.sideMenuMake(true))
            case .homeTabbar(.delegate(.moveToDirect(workSpaceID: let workSpaceID))):
                state.selectedTab = .dm
                
                return .run { send in
                    await send(.dmsTabbar(.parentAction(.getWorkSpaceId(workSpaceID))))
                }
                
                // MARK: 로그아웃 발생시
            case .homeTabbar(.delegate(.moveToOnBoardingView)):
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
            case .dmsTabbar(.delegate(.moveToOnBoardingView)):
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
            case .settingTabbar(.delegate(.moveToOnBoardingView)):
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$makeWorkSpaceState, action: \.sendWorkSpaceMakeAction) {
            WorkSpaceInitialFeature()
        }
        .ifLet(\.sideMenuState, action: \.sidebar) {
            WorkSpaceSideFeature()
        }
        
    }
}


extension AlertState where Action == RootFeature.Action.Alert {
    
    static let refreshDeadAlert = Self {
        TextState("재 로그인 필요")
    } actions: {
        ButtonState(role: .destructive, action: .refreshTokenDead) {
            TextState("확인")
        }
    } message: {
        TextState("로그인 시간이 만료되어 재로그인이 필요합니다 ㅠㅠ")
    }
}
