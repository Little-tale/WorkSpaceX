//
//  DMSCoordinator.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import TCACoordinators
import ComposableArchitecture

@Reducer(state: .equatable)
enum DMSListScreens {
    case dmHome(DMSListFeature)
    case dmChat(DMSChatFeature)
    case profileInfo(ProfileInfoFeature)
    case profileEdit(ProfileInfoEditFeature)
    // sheet
    case memberAdd(AddMemberFeature)
    
    // 결제
    case storeListView(StoreListFeature)
}

@Reducer
struct DMSCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let uuid = UUID()
        
        let profileView = UUID()
        let storeView = UUID()
        
        var currentWorkSpaceId: String?
        var identeRoutes: IdentifiedArrayOf<Route<DMSListScreens.State>>
        
        static let initialState = State(identeRoutes: [.root(.dmHome(DMSListFeature.State(id: uuid)), embedInNavigationView: true)])
        
    }
    
    
    enum Action {
        case router(IdentifiedRouterActionOf<DMSListScreens>)
        
        case parentAction(ParentAction)
        
        case delegate(Delegate)
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        
        enum Delegate {
            case moveToOnBoardingView
        }
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .parentAction(.getWorkSpaceId(workSpaceID)):
                state.currentWorkSpaceId = workSpaceID
                let id = workSpaceID
                return .run { send in
                    await send(.router(.routeAction(id: DMSCoordinator.State.uuid, action: .dmHome(.parentAction(.getWorkSpaceId(id))))))
                }
            case .router(.routeAction(id: _, action: .dmHome(.delegate(.clickedAddMember)))):
                
                if let id = state.currentWorkSpaceId {
                    state.identeRoutes.presentSheet(.memberAdd(AddMemberFeature.State( currentWorkSpaceID: id)), embedInNavigationView: true)
                }
                
                /// 자신의 프로필 이동하기 클릭하였을때
            case .router(.routeAction(id: _, action: .dmHome(.delegate(.moveToProfileView)))):
                let uuid = state.profileView
                if let id = UserDefaultsManager.userID {
                    state.identeRoutes.push(
                        .profileInfo(
                            ProfileInfoFeature.State(
                                id: uuid,
                                userType: .me(userID: id)
                            )
                        )
                    )
                }
               /// 닉네임 수정으로 전환
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToNickNameChange(let model))))):
                state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                    editType: .nickName,
                    model: model
                )))
                
                
                /// 연락처 수정으로 전환
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToContackChange(let model))))):
                state.identeRoutes.push(.profileEdit(ProfileInfoEditFeature.State(
                    editType: .contact,
                    model: model
                )))
                
                // 등록이 완료될경우 
            case .router(.routeAction(id: _, action: .profileEdit(.delegate(.regSuccess)))):
                
                state.identeRoutes.pop()
                
                // 다른 사용자 프로필로 이동할 경우
            case .router(.routeAction(id: _, action: .dmChat(.delegate(.otehrUserProfile(userID: let userID))))):
                let uuid = state.profileView
                
                state.identeRoutes.push(
                    .profileInfo(ProfileInfoFeature.State(
                        id: uuid,
                        userType: .other(userID: userID)
                    ))
                )
                
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToOnBoardingView)))):
                
                return .run { send in
                    await send(.delegate(.moveToOnBoardingView))
                }
                
                /// 결제로 이동
            case .router(.routeAction(id: _, action: .profileInfo(.delegate(.moveToCoinShop)))):
                let uuid = state.storeView
                
                state.identeRoutes.push(.storeListView(StoreListFeature.State(id: uuid)))
                
            case .router(.routeAction(id: _, action: .memberAdd(.alertSuccessTapped))):
                
                state.identeRoutes.dismiss()
                let id = DMSCoordinator.State.uuid
                
                return .run { send in
                    await send(.router(.routeAction(id: id, action: .dmHome(.onAppaer))))
                }
            case .router(.routeAction(id: _, action: .memberAdd(.dismissButtonTapped))):
                
                state.identeRoutes.dismiss()
                
                // DMS 탭에서 프로필 선택시
            case .router(.routeAction(id: _, action: .dmHome(.delegate(.moveToDMS(let model, let workSpaceId))))):
                if let userid = UserDefaultsManager.userID {
                    state.identeRoutes.push(.dmChat(
                        DMSChatFeature.State(
                            workSpaceID: workSpaceId,
                            userID: userid,
                            otherUserID: model.userID)))
                }
                // DMS 탭에서 채팅룸을 선택하였을때
            case .router(.routeAction(id: _, action: .dmHome(.delegate(.moveToDMSForRoom(model: let model, workSpaceID: let workSpaceID))))):
                if let userid = UserDefaultsManager.userID {
                    state.identeRoutes.push(.dmChat(DMSChatFeature.State(
                        workSpaceID: workSpaceID,
                        userID: userid,
                        otherUserID: model.user.userID
                    )))
                }
                //otherUserID
            case .router(.routeAction(id: _, action: .dmChat(.delegate(.popClicked(let roomID))))):
                WorkSpaceReader.shared.observeDMSStop(roomID)
                WSXSocketManager.shared.stopAndRemoveSocket()
                // 소켓 연결시 해제 해주어야 함.
                state.identeRoutes.pop()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.identeRoutes, action: \.router)
    }
}
