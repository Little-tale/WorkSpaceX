//
//  EmailLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EmailLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        
        Reduce {state, action in
            switch action {
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
            }
            return .none
        }
        
    }
    
}
