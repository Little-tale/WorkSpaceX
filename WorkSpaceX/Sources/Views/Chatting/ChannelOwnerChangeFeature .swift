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
        
    }
    
    enum Action {
        case onAppar
        case delegate(Delegate)
        
        
        case backButtonTapped
        enum Delegate {
            case backButtonTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .backButtonTapped:
                return .run { send in await send(.delegate(.backButtonTapped))}
                
            default:
                break
            }
            return .none
        }
        
    }
    
}
