//
//  SearchFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SerachFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID
        var currentWorkSpaceID: String? = nil
        
        var navigationTitle = "검색"
    }
    
    enum Action {
        case onAppear
        case parentAction(ParentAction)
        case delegate(Delegate)
        
        enum ParentAction {
            case sendToWorkSpaceID(String)
        }
        enum Delegate {
            
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
             
            case let .parentAction(.sendToWorkSpaceID(workSpaceID)):
                state.currentWorkSpaceID = workSpaceID
                
            default:
                break
            }
            return .none
        }
    }
    
}
