//
//  WorkSpaceSideFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@Reducer
struct WorkSpaceSideFeature {
    
    @ObservableState
    struct State: Equatable {
        var id = UUID()
        var currentCase: viewCase = .empty
        
    }
    
    enum Action {
        case onAppear(Results<WorkSpaceRealmModel>)
        case goBackToRoot
    }
    
    enum viewCase {
        case empty
        case over
    }
   
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case let .onAppear(models):
                print("사이드 매뉴 입장",models)
            default:
                break
            }
            return .none
            
        }
        
    }
}
