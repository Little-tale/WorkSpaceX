//
//  SettingCoordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/7/24.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum SettingScreens {
    case home(ProfileInfoFeature)
    case profileEdit(ProfileInfoEditFeature)
    // 결제
    case storeListView(StoreListFeature)
}


@Reducer
struct SettingCoordinator {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        
        var storeView = UUID()
        
        var currentWorkSpaceId: String?
        var currentUserID: String?
        
        static let homeID = UUID()
        static var meID: String = ""
        
        
        var identeRoutes: IdentifiedArrayOf<Route<SettingScreens.State>>
        
        static let initialState = State(identeRoutes: [.root(.home(
            ProfileInfoFeature.State(
            id: homeID,
            userType: .me(userID: meID),
            tabbarHidden: false)
        ), embedInNavigationView: true)])
        
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SettingScreens>)
        
        case delegate(Delegate)
        
        case updateUserID
        
        case parentAction(ParentAction)
        
        enum ParentAction {
            case getWorkSpaceId(String)
            case getcurrentUserID(String)
        }
        
        enum Delegate {
            case moveToOnBoardingView
        }
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
                
            case .parentAction(.getWorkSpaceId(let work)):
                state.currentWorkSpaceId = work
                return .run { send in
                    await send(.updateUserID)
                }
            case .updateUserID:
                if let userID = UserDefaultsManager.userID {
                    state.currentUserID = userID
                }
                
            case .parentAction(.getcurrentUserID(let user)):
                state.currentUserID = user
                let id = SettingCoordinator.State.homeID
                
                return .run { send in
                    await send(.router(.routeAction(id: id, action: .home(.parentAction(.updateID(.me(userID: user)))))))
                }
                
                /// 닉네임 수정으로 전환
             case .router(.routeAction(id: _, action: .home(.delegate(.moveToNickNameChange(let model))))):
                
                 state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                     editType: .nickName,
                     model: model
                 )))
                 
                 
                 /// 연락처 수정으로 전환
             case .router(.routeAction(id: _, action: .home(.delegate(.moveToContackChange(let model))))):
                 state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                     editType: .contact,
                     model: model
                 )))
                
                // 등록이 완료될경우
            case .router(.routeAction(id: _, action: .profileEdit(.delegate(.regSuccess)))):
                
                state.identeRoutes.pop()
                
            case .router(.routeAction(id: _, action: .home(.delegate(.moveToOnBoardingView)))):
                
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
                
                /// 결제로 이동
            case .router(.routeAction(id: _, action: .home(.delegate(.moveToCoinShop(let coin))))):
                let uuid = state.storeView
                
                state.identeRoutes.push(.storeListView(StoreListFeature.State(
                    id: uuid,
                    currentCoinCount: coin))
                )
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
    
}
