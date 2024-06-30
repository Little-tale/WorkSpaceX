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
        
        enum Delegate {
            case backButtonTapped
        }
    }
    
    enum AlertAction: Equatable {
        case reallyChangeOwner(name: String)
        
        var title: String {
            switch self {
            case let .reallyChangeOwner(name):
                return name + " 님을 관리자로 지정하시겠습니까?"
            }
        }
        
        var message: String {
            switch self {
            case .reallyChangeOwner:
                return "채널 관리자는 다음과 같은 권한이 있습니다.\n" + """
* 채널 이름 또는 설명 변경
* 채널 삭제
"""
            }
        }
        var actionTitle: String {
            switch self {
            case .reallyChangeOwner:
                return "확인"
            }
        }
        var alertMode: AlertMode {
            switch self {
            case .reallyChangeOwner:
                return .cancelWith
            }
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    
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
                state.alertState = .reallyChangeOwner(name: model.nickname)
                state.currentUserSelected = model
                
            case let .alertAction(action):
                if action == nil { state.currentUserSelected = nil }
                state.alertState = action
                
            case let .alertActted(action):
                switch action {
                case .reallyChangeOwner(name: let name):
                    <#code#>
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
