//
//  DocumentFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DocumentFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        let url: URL
    }
    
    enum Action {
        
        case onAppear
        
        case parentAction(ParentAction)
        case delegate(Delegate)
        
        enum ParentAction {
            
        }
        
        enum Delegate {
            
        }
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            default:
                break
            }
            return .none
        }
    }
    
}
