//
//  DMSListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMSListFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        var currentWorkSpaceID: String = ""
        
    }
    
    enum Action {
        case onAppaer
        
        case parentAction(ParentAction)
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppaer:
                print(state.currentWorkSpaceID)
            case let .parentAction(.getWorkSpaceId(id)):
                state.currentWorkSpaceID = id
                
            default:
                break
            }
            return .none
        }
    }
    
}
