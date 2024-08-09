//
//  WorkSpaceEditFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/18/24.
//

import UIKit.UIImage
import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceEditFeature {
    
    @ObservableState
    struct State: Equatable {
        var imagePick = CustomImagePickFeature.State()
        var showImagePicker = false
        let navigationTitle = "워크스페이스 편집"
        var workSpaceName = ""
        var workSpaceIntroduce = ""
        var regButtonState = false
        var image: Data? = nil
       
        var successMessage: String? = nil
        var showProgressView = false
        
        var workSpaceID = ""
        
        var alertCase: AlertCase? = nil
        let workSpaceNameFieldType = WorkSpaceNameFieldType()
        let workSpaceExplainType = WorkSpaceExplainType()
    }
    
    struct WorkSpaceNameFieldType: Equatable {
        let headerTitle = "워크스페이스 이름"
        let placeHolderTitle = "워크스페이스 이름을 입력하세요 (필수)"
    }
    
    struct WorkSpaceExplainType: Equatable {
        let headerTitle = "워크스페이스 설명"
        let placeHolderTitle = "워크스페이스 설명를 설명하세요 (옵션)"
    }
    
    enum AlertCase: Equatable {
        case error(String)
        case success(String)
        
        var title: String {
            switch self {
            case .error:
                "에러 발생"
            case .success:
                "수정 완료"
            }
        }
        
        var message: String {
            switch self {
            case .error(let text), .success(let text):
                text
            }
        }
        
        var action: String {
            return "확인"
        }
    }
    
    enum Action: BindableAction {
        case getModel(WorkSpaceRealmModel)
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickFeature.Action)
        
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        
        case alertCase(AlertCase?)
        
        case regSuccess(WorkSpaceEntity)
        case realmRegSuccess
        
        case ifNeedSuccessTrigger
        case alertSuccessTapped
    }
    
    @Dependency(\.workspaceDomainRepository) var repository
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickFeature()
        }
        core()
    }
}


extension WorkSpaceEditFeature {
    
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case let .getModel(model):
                
                return getModelSideEffect(state: &state, model: model)
            case .showImagePicker:
                state.showImagePicker = true
                
            case let .imagePickerData(data):
                
                if let data {
                    state.image = data
                    return .run { send in
                        await send(.imagePickFeature(.success(data)))
                    }
                } else {
                    return .run { send in
                        await send(.imagePickFeature(.empty))
                    }
                }
                
            case .binding:
                state.regButtonState = state.workSpaceName != ""
                
            case .regButtonTapped:
                
                return regButtonSideEffect(state: &state)
            case let .regSuccess(model):
                
                return .run { send in
                    try await realmRepo.upsertWorkSpace(response: model)
                    
                    await send(.realmRegSuccess)
                    
                } catch: { error, send in
                    print(error)
                    await send(.alertCase(.error("저장중 오류가 발생하였습니다.")))
                }
                
            case .realmRegSuccess:
                return .run { send in
                    await send(.alertCase(.success("저장 되었습니다.")))
                }
            case let .alertCase(alert):
                state.alertCase = alert
                
            case .alertSuccessTapped:
                return .run { send in
                    await send(.ifNeedSuccessTrigger)
                }
                
            default :
                break
            }
            
            return .none
        }
    }
}

extension WorkSpaceEditFeature {
    
    private func getModelSideEffect(state: inout State, model: WorkSpaceRealmModel) -> Effect<Action> {
        print("받아옴, \(model)")
        state.workSpaceName = model.workSpaceName
        state.workSpaceIntroduce = model.introduce ?? ""
        
        state.workSpaceID = model.workSpaceID
        
        state.regButtonState = state.workSpaceName != ""
        
        let imageUrl = model.coverImage
        
        return .run { send in
            await send(.imagePickFeature(.ifURLString(imageUrl)))
        }
    }
    
    private func regButtonSideEffect(state: inout State) -> Effect<Action> {
        let id = state.workSpaceID
        
        let request = EditWorkSpaceRequest(
            name: state.workSpaceName,
            description: state.workSpaceIntroduce,
            image: state.image
        )
        
        return .run { send in
            let result = try await repository.modifySpaceRequest(request, id)
            await send(.regSuccess(result))
            
        } catch: { error, send in
            if let error = error as? WorkSpaceEditAPIError {
                if !error.ifDevelopError {
                    await send(.alertCase(.error(error.message)))
                } else { print(error) }
            
            } else {
                print(error)
            }
        }
    }
}
