//
//  StoreListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation
import ComposableArchitecture
import iamport_ios

@Reducer
struct StoreListFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID
        var currentCoinCount: Int
        var storeViewState: StoreViewState = .loading
        var currentCoinItems:  [StoreItemEntity] = []
        var explainState: ExplainState? = nil
        let navigationTitle = "코인샵"
        var paymentModel: IamportPayment? = nil
        
        var payMentBool: Bool = false
        
        
        let userCode = APIKey.userCode
        
        static func == (lhs: StoreListFeature.State, rhs: StoreListFeature.State) -> Bool {
            return lhs.id == rhs.id
        }
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
        
        case catchToCoinItems([StoreItemEntity])
        case selectedItem(StoreItemEntity)
        
        case paymentModel(IamportPayment?)
        case paymentResponse(IamportResponse?)
        case payMentBool(Bool)
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
                    await send(.catchToCoinItems(result))
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
            case let .catchToCoinItems(items):
                state.currentCoinItems = items
                state.storeViewState = .show
                
            case let .selectedItem(item):
                let model = storeRepo.storeMapper.makeIamport(
                    item
                )
                return .run { send in
                    await send(.paymentModel(model))
                }
                
            case let .exPlainBind(bind):
                state.explainState = bind
                
            case let .payMentBool(bool):
                state.payMentBool = bool
                if !bool { state.paymentModel = nil }
                
            case let .paymentModel(model):
                state.paymentModel = model
                
                if model != nil {
                    state.payMentBool = true
                } else {
                    state.payMentBool = false
                }
                
                
            default:
                break
            }
            
            return .none
        }
    }
}
