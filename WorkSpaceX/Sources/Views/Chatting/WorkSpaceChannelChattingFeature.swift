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
        
        case onAppear
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let channelID = state.channelID
                let workSpaceID = state.workSpaceID
                
                print("네트워크 요청해야함...")
                
            default:
                break
            }
            return .none
        }
        
    }
    
}
