//
//  ChannelOwnerChangeFeature .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/29/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChannelOwnerChangeFeature {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        let workSpaceID: String
        let channel: ChanelEntity
        
        var users: [WorkSpaceMembersEntity] = []
        
        var userID: String? = nil
        
        var alertState: AlertAction? = nil
        
        var currentUserSelected: WorkSpaceMembersEntity? = nil
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        case selectedUser(WorkSpaceMembersEntity)
        
        case backButtonTapped
        
        case alertAction(AlertAction?)
        
        case alertActted(AlertAction)
        
        case realmUpsert(ChanelEntity)
        
        enum Delegate {
            case backButtonTapped
        }
    }
    
    enum AlertAction: Equatable {
        
        case reallyChangeOwner(name: String, id: String)
        case error(message: String)
        
        var title: String {
            switch self {
            case let .reallyChangeOwner(name,_):
                return name + " 님을 관리자로 지정하시겠습니까?"
            case .error:
                return "에러"
            }
        }
        
        var message: String {
            switch self {
            case .reallyChangeOwner:
                return "채널 관리자는 다음과 같은 권한이 있습니다.\n" + """
* 채널 이름 또는 설명 변경
* 채널 삭제
"""
            case let .error(message):
                return message
            }
        }
        var actionTitle: String {
            switch self {
            case .reallyChangeOwner:
                return "확인"
            case .error:
                return "확인"
            }
        }
        var alertMode: AlertMode {
            switch self {
            case .reallyChangeOwner:
                return .cancelWith
            case .error:
                return .onlyCheck
            }
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                var models: [WorkSpaceMembersEntity] = []
                
                if let userID = UserDefaultsManager.userID {
                    state.userID = userID
                    models = filterMe(state.channel, userID: userID)
                }
                
                state.users = models
                
            case .backButtonTapped:
                return .run { send in await send(.delegate(.backButtonTapped))}
                
            case let .selectedUser(model):
                state.alertState = .reallyChangeOwner(name: model.nickname, id: model.userID)
                state.currentUserSelected = model
                
            case let .alertAction(action):
                if action == nil { state.currentUserSelected = nil }
                state.alertState = action
                
            case let .alertActted(action):
                switch action {
                case .reallyChangeOwner(_, let id):
                    let workSpaceID = state.workSpaceID
                    let channelID = state.channel.channelId
                    return .run { send in
                        let result = try await workSpaceRepo.channelOWnerChanged(
                            workSpaceID,
                            channelID,
                            id
                        )
                        await send(.realmUpsert(result))
                    } catch: { error, send in
                        if let error = error as? ChannelOwnerChangedAPIError {
                            if error.ifReFreshDead {
                                RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                            } else if !error.ifDevelopError {
                                await send(.alertAction(.error(message: error.message)))
                            } else {
                                print(error)
                            }
                        } else {
                            print(error)
                        }
                    }
                default:
                    break
                }
                
            case let .realmUpsert(model):
                
                return .run { send in
                    try await realmRepo.upserWorkSpaceChannel(channel: model)
                } catch: { error, send in
                    print(error)
                }
                
            default:
                break
            }
            return .none
        }
        
    }
    
}
extension ChannelOwnerChangeFeature {
    
    private func filterMe(_ model: ChanelEntity, userID: String) -> [WorkSpaceMembersEntity] {
        return model.users.filter { $0.userID != userID }
    }
    
}
