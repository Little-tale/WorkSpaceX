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
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        case selectedUser(WorkSpaceMembersEntity)
        
        case backButtonTapped
        enum Delegate {
            case backButtonTapped
        }
    }
    
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
