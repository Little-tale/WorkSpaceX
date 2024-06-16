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
        var currentCase: viewCase = .loading
        var currentCount = 0
    }
    
    enum Action {
        case onAppear(Results<WorkSpaceRealmModel>)
        case goBackToRoot
        case checkCount
        case sendToMakeWorkSpace
    }
    
    enum viewCase {
        case loading
        case empty
        case over
    }
   
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case let .onAppear(models):
                state.currentCount = models.count
                print("사이드 매뉴 입장",models)
                return .run { send in
                    try await Task.sleep(for: .seconds(0.44))
                    await send(.checkCount)
                }
            case .checkCount:
                if state.currentCount == 0 {
                    state.currentCase = .empty
                } else {
                    state.currentCase = .over
                }
            default:
                break
            }
            return .none
        }
        
    }
}
