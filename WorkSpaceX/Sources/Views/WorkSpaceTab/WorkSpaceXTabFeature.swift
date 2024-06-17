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
        
        var sideMenuState: WorkSpaceSideFeature.State?
        
        // 탭뷰 자체적으로 프레젠테이션 하겠습니다.
        @Presents var makeWorkSpaceState: WorkSpaceInitalFeature.State?
        
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
        
        // case sideMenuCoordiAction(SideMenuCoordinator.Action)
        case sideMenuMake(Bool)
        
        case sendWorkSpaceMakeAction(PresentationAction<WorkSpaceInitalFeature.Action>)
        case makeWorkSpaceStart
        case workSpaceRegSuccess
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.userDomainRepository) var userDominRepo
//    @Dependency(\.realmRepository) var realmeRepo
    static let realmRepo = RealmRepository()
    
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
                    state.sideMenuState = WorkSpaceSideFeature.State()
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
                WorkSpaceTabCoordinator.realmRepo.upsertUserModel(response: user)
                return .none
                
            case let .saveRealmOfWorkSpaces(workSpaces):
                WorkSpaceTabCoordinator.realmRepo.upsertWorkSpaces(responses: workSpaces)
                if workSpaces.isEmpty {
                    return .run { send in
                        await send(.showEmptyView(true))
                    }
                }
                return .none
                
            case let .showEmptyView(bool):
                state.ifNoneSpace = bool
                return .none
               
            case .sidebar(.sendToMakeWorkSpace):
                
                return .run { send in
                    await send(.sideMenuMake(false))
                    try await Task.sleep(for: .seconds(0.3))
                    await send(.makeWorkSpaceStart)
                }
            case .makeWorkSpaceStart:
                state.makeWorkSpaceState = WorkSpaceInitalFeature.State()
               
            case .sidebar(.goBackToRoot):
                return .run{ send in
                    await send(.sideMenuMake(false))
                }
            case let .sidebar(.selectedModeltoPresent(model)):
                state.sideMenuOpen = false
                return .none
                
            case .sendWorkSpaceMakeAction(.presented(.regSuccess)):
                
                return .run { send in
                    await send(.workSpaceRegSuccess)
                }
            case .workSpaceRegSuccess:
                return .run { send in await send(.onAppear) }
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$makeWorkSpaceState, action: \.sendWorkSpaceMakeAction) {
            WorkSpaceInitalFeature()
        }
        .ifLet(\.sideMenuState, action: \.sidebar) {
            WorkSpaceSideFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}


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
