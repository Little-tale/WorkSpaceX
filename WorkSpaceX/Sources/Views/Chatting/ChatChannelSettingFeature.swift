//
//  ChatChannelSettingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import Foundation
import ComposableArchitecture


@Reducer
struct ChatChannelSettingFeature {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        let channelEntity: ChanelEntity
        let isOwner: Bool
        
        var channelName: String = "#"
        var channelIntro: String = ""
        var usersCount: String = "(0)"
        var users: [WorkSpaceMembersEntity] = []
    }
    
    
    enum Action {
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                
                state.channelName = "# " + state.channelEntity.name
                
                state.channelIntro = state.channelEntity.description
                
                state.users = state.channelEntity.users
                let count = state.channelEntity.users.count
                state.usersCount = "(\(count))"
            }
            
            return .none
        }
    }
    
}
