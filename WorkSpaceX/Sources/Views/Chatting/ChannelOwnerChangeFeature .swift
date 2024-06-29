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
        
    }
    
    
    
}
