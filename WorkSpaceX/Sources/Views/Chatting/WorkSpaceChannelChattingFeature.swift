//
//  WorkSpaceChannelChattingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceChannelChattingFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID = UUID()
        let channelID: String
        let workSpaceID: String
    }
    
    enum Action {
        case popClicked
    }
    
    
}
