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
        var currentCoinCount: Int
        let storeViewStat: StoreViewState = .loading
        
        var explainState: ExplainState? = nil
    }
    enum StoreViewState {
        case loading
        case show
    }
    
    @Dependency(\.storeRepository) var storeRepo
    
    enum Action {
        case onAppear
        
        case delegate(Delegate)
        case parentAction(ParentAction)
        
        case explinShow(Bool)
        case exPlainBind(ExplainState?)
        
        enum Delegate {
            
        }
        enum ParentAction {
            
        }
    }
    
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let result = try await storeRepo.storeList()
                    
                    print("성공 \(result)")
                } catch: { error, send in
                    if let error = error as? StoreListApiError {
                        print(error)
                    }
                    print(error) // 해당 에선 에러 코드가 없음
                }
                
            case .explinShow(let bool):
                return .run { send in
                    if bool {
                        await send(.exPlainBind(ExplainState()))
                    } else {
                        await send(.exPlainBind(nil))
                    }
                    
                }
                
            case let .exPlainBind(bind):
                state.explainState = bind
                
            default:
                break
            }
            
            return .none
        }
    }
}
