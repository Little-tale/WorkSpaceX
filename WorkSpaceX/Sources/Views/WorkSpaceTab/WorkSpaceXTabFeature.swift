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
            homeState: WorkSpaceListCordinator.State.initialState
        )
        
        var selectedTab: Tab
        // sidebar State
        
        var firstInTrigger = true
        
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
        var currentCount = 0
        var currentModels: [WorkSpaceRealmModel] = []
        
        // Refresh
        var refreshAlert: Bool = false
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
        case refreshChecked
        // case sideMenuCoordiAction(SideMenuCoordinator.Action)
        case sideMenuMake(Bool)
        
        case sendWorkSpaceMakeAction(PresentationAction<WorkSpaceInitalFeature.Action>)
        case makeWorkSpaceStart(Bool)
        case workSpaceRegSuccess(id: String)
        
        case workSpaceSubscribe
        case currentModelCatch([WorkSpaceRealmModel])
        
        case noWorkSpaceTrigger
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
                
                    let profile = try await userDominRepo.myProfile()
                    await send(.saveRealmOfProfile(profile))
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
                    if workSpaces.isEmpty {
                        
                        await send(.showEmptyView(true))
                        
                    }
                } catch: { error, _ in
                    print(error)
                }
                
                
            case let .showEmptyView(bool):
                state.ifNoneSpace = bool
                return .none
               
            case .sidebar(.sendToMakeWorkSpace):
                
                return .run { send in
                    await send(.sideMenuMake(false))
                    try await Task.sleep(for: .seconds(0.3))
                    await send(.makeWorkSpaceStart(true))
                }
            case .makeWorkSpaceStart(let bool):
                if bool {
                    state.makeWorkSpaceState = WorkSpaceInitalFeature.State()
                } else {
                    state.makeWorkSpaceState = nil
                }
                
               
            case .sidebar(.goBackToRoot):
                return .run{ send in
                    await send(.sideMenuMake(false))
                }
            case let .sidebar(.selectedModeltoPresent(model)):
                state.sideMenuOpen = false
                print(model)
               
                let worSpaceId = model.workSpaceID
                
                return .run { send in
                    await send(.homeTabbar(.sendToRootWorkSpaceID(worSpaceId)))
                }
                
            case .sidebar(.removeSuccessAlertTapped) :
                if state.currentCount <= 0 {
//                    state.sideMenuOpen = false
                    UserDefaultsManager.workSpaceSelectedID = ""
                    return .run { send in
                        await send(.noWorkSpaceTrigger)
                    }
                } else if let first = state.currentModels.first {
                    return .send(.homeTabbar(.sendToRootWorkSpaceID(first.workSpaceID)))
                    
                }
            case .sendWorkSpaceMakeAction(.presented(.realmRegSuccess(let id))):
                return .run { send in
                    await send(.workSpaceRegSuccess(id: id))
                }
            case .workSpaceRegSuccess(let id):
                UserDefaultsManager.workSpaceSelectedID = id
                
                return .run { send in
                     await send(.homeTabbar(.sendToRootWorkSpaceID(id)))
                    await send(.onAppear)
                }

            
            case .workSpaceSubscribe:
                return .run { send in
                    let result = try await workSpaceRepo.findMyWordSpace()
                    
                    await send(.saveRealmOfWorkSpaces(result))
                    
                    if UserDefaultsManager.workSpaceSelectedID != "" {
                        await send(.homeTabbar(.sendToRootWorkSpaceID(UserDefaultsManager.workSpaceSelectedID)))
                    } else if let first = result.first {
                        UserDefaultsManager.workSpaceSelectedID
                        = first.workSpaceID
                        await send(.homeTabbar(.sendToRootWorkSpaceID(UserDefaultsManager.workSpaceSelectedID)))
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
                if state.firstInTrigger {
                    state.firstInTrigger = false
                    state.ifNoneSpace = count <= 0
                    // 이게 원인 같아 보임.
                }
            
                // HomeTabDelegte
            case .homeTabbar(.delegate(.openSideMenu)):
                return .send(.sideMenuMake(true))
                
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

/*
 
 // - > realmModel 은 다른 쓰레드로 넘기면 무제가 생김
 // run {} 구문 안은 Swift Concurrency 즉 어떤 쓰레드로 갈지 전혀 모름. 즉 run 구문안에서 렘 모델을 넘겨주거나 무언가를 하게 되는순간 터짐 ex) print(model.id) 터짐.
 // Thread 5: "Realm accessed from incorrect thread."
 // 해결 방법은 꽤 단순한데.
 // run 옆에 MainActor를 명시 하는방법이 있음
 
 let result = try await workSpaceRepo.findMyWordSpace()
 
 print("현재 스페이스 갯수")
 dump(result)
 await send(.saveRealmOfWorkSpaces(result))
 
 
 if let error = error as? WorkSpaceMeError {
     
     if error.ifDevelopError {
         print(error.message)
     } else {
         print(error)
     }
 } else
 */

//
