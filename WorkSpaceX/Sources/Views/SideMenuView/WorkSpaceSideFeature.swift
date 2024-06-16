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
    
//    @ObservedResults(WorkSpaceRealmModel.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: true))
//    var workSpaceModel
    
    @ObservableState
    struct State: Equatable {
        var id = UUID()
        var currentCase: viewCase = .loading
        var currentCount = 0
        var currentModels:[WorkSpaceRealmModel] = []
        
    }
    
    @Dependency(\.realmRepository) var realmRepo
    
    enum Action {
        case onAppear
        case goBackToRoot
        case checkCount
        case sendToMakeWorkSpace
        case currentModelCatch([WorkSpaceRealmModel])
    }
    
    enum viewCase {
        case loading
        case empty
        case over
    }
   
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case .onAppear:
                
                return .run { send in
                    for await models in  realmRepo.observeChanges(for: WorkSpaceRealmModel.self, sorted: "createdAt", ascending: true) {
                        await send(.currentModelCatch(models))
                    }
                }
                
            case .checkCount:
                if state.currentCount == 0 {
                    state.currentCase = .empty
                } else {
                    state.currentCase = .over
                }
                
            case let .currentModelCatch(models):
                state.currentCount = models.count
                state.currentModels = models
                
                return .run { send in
                    try await Task.sleep(for: .seconds(0.4))
                    await send(.checkCount)
                }
    
            default:
                break
            }
            return .none
        }
        
    }
}
/*
 case let .workSpaceModelsChanged(models):
     print("사이드 매뉴 입장")
     state.currentModels = Array(models)
     if state.currentCount != models.count {
         state.currentCount = models.count
         return .run { send in
             try await Task.sleep(for: .seconds(0.44))
             await send(.checkCount)
         }
     }
 */
