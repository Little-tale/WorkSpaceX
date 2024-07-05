//
//  StoreListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct StoreListFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID
        let storeViewStat: StoreViewState = .loading
    }
    enum StoreViewState {
        case loading
        case show
    }
    
    enum Action {
        case onAppear
        
        case delegate(Delegate)
        case parentAction(ParentAction)
        
        enum Delegate {
            
        }
        enum ParentAction {
            
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
