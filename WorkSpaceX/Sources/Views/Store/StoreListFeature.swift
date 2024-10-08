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
        
        var paymentBool: Bool = false
        
        var alertCase: AlertCase? = nil
        
        let userCode = APIKey.userCode
        
        // 결제전 프로필 조회를 통해 리프레시 토큰이 죽을 확률을 제거
        
        static func == (lhs: StoreListFeature.State, rhs: StoreListFeature.State) -> Bool {
            return lhs.id == rhs.id
        }
    }
    enum StoreViewState {
        case loading
        case show
    }
    
    enum AlertCase:Equatable {
        case error(String)
        case success(String)
        
        var title: String {
            switch self {
            case .error:
                return "에러"
            case .success:
                return "성공"
            }
        }
        var message: String {
            switch self {
            case .error(let string):
                return string
            case .success(let string):
                return string
            }
        }
    }
    
    @Dependency(\.storeRepository) var storeRepo
    @Dependency(\.userDomainRepository) var userRepo
    
    enum Action {
        case onAppear
        
        case delegate(Delegate)
        case parentAction(ParentAction)
        
        case explainShow(Bool)
        case exPlainBind(ExplainState?)
        
        case catchToCoinItems([StoreItemEntity])
        case selectedItem(StoreItemEntity)
        
        case paymentModel(IamportPayment?)
        case paymentResponse(IamportResponse?)
        case paymentBool(Bool)
        
        case alertCase(AlertCase?)
        
        case catchToStoreValidEntity(StoreValidEntity)
        
        enum Delegate {
            
        }
        enum ParentAction {
            
        }
    }
    
    enum key: Hashable {
        case throttle
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension StoreListFeature {
    
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return onAppearSideEffect()
                
            case .explainShow(let bool):
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
                return selectedItemSideEffect(item: item)
                
            case let .exPlainBind(bind):
                state.explainState = bind
                
            case let .paymentBool(bool):
                state.paymentBool = bool
                if !bool { state.paymentModel = nil }
                
            case let .paymentModel(model):
                state.paymentModel = model
                
                if model != nil {
                    state.paymentBool = true
                } else {
                    state.paymentBool = false
                }
                
            case let .paymentResponse(model):
                return paymentSideEffect(model: model)
                
            case let .catchToStoreValidEntity(model):
                state.currentCoinCount += model.sesacCoin
                return .run { send in
                    await send(.alertCase(.success("결제가 완료 되었습니다.")))
                }
            case let .alertCase(caseOf):
                state.alertCase = caseOf
            default:
                break
            }
            
            return .none
        }
    }
}

extension StoreListFeature {
    
    private func onAppearSideEffect() -> Effect<Action> {
        return .run { send in
            let result = try await storeRepo.storeList()
            await send(.catchToCoinItems(result))
        } catch: { error, send in
            if let error = error as? StoreListApiError {
                print(error)
            }
            print(error) // 해당 에선 에러 코드가 없음
        }
    }
    
    private func paymentSideEffect(model: IamportResponse?) -> Effect<Action> {
        if let model{
            guard let impID = model.imp_uid,
                  let merID = model.merchant_uid else {
                return .run { send in
                    await send(.alertCase(.error("결제 실패: 결제 되었을시 담당자에게 연락 바랍니다.")))
                }
            }
            print(impID, merID)
            return .run { send in
                let result = try await storeRepo.requestValid(
                    impUid: impID,
                    merChantUID: merID
                )
                await send(.catchToStoreValidEntity(result))
            }
            catch: { error, send in
                if let error = error as? StoreValidApiError {
                    if !error.ifDevelopError {
                        await send(.alertCase(.error(error.message)))
                    }
                } else {
                    print(error)
                }
            }
        }
        return .none
    }
    
    private func selectedItemSideEffect(item: StoreItemEntity) -> Effect<Action> {
        let model = storeRepo.storeMapper.makeIamport(
            item
        )
        return .run { send in
            // 리프레시 토큰 죽을 가능성을 위해 한번 조회를 통해 무회
            let _ = try await userRepo.myProfile()
            await send(.paymentModel(model))
        } catch: { error, send in
            print(error)
        }
    }
}
