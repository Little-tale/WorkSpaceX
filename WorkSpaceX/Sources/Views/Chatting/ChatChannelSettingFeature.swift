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
        let channelID: String
        let isOwner: Bool
    }
    
    enum Action {
        case onAppear
    }
    
}
