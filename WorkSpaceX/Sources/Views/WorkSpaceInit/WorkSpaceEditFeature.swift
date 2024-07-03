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
        var imagePick = CustomImagePickPeature.State()
        var showImagePicker = false
        var workSpaceName = ""
        var workSpaceIntroduce = ""
        var regButtonState = false
        var image: Data? = nil
        var errorMessage: String? = nil
        var successMessage: String? = nil
        var showPrograssView = false
        
        var workSpaceID = ""
    }
    
    enum Action: BindableAction {
        case getModel(WorkSpaceRealmModel)
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        
        case errorMessage(String)
        case successMessage(String)
        
        case regSuccess(WorkSpaceEntity)
        case realmRegSuccess
        
        case ifNeedSuccessTrigger
        case alertSuccessTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.workspaceDomainRepository) var repository
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            
            switch action {
            case let .getModel(model):
                
                print("받아옴, \(model)")
                state.workSpaceName = model.workSpaceName
                state.workSpaceIntroduce = model.introduce ?? ""
                
                state.workSpaceID = model.workSpaceID
                
                state.regButtonState = state.workSpaceName != ""
                
                let imageUrl = model.coverImage
                
                return .run { send in
                    await send(.imagePickFeature(.ifURLString(imageUrl)))
                }
                
                
            case .dismissButtonTapped:
                
                return .run { send in
                    await self.dismiss()
                }
                
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
                let id = state.workSpaceID
                
                let request = EditWorkSpaceReqeust(
                    name: state.workSpaceName,
                    description: state.workSpaceIntroduce,
                    image: state.image
                )
                
                return .run { send in
                    let result = try await repository.modifySpaceReqeust(request, id)
                    await send(.regSuccess(result))
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceEditAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error) }
                    
                    } else {
                        print(error)
                    }
                }
                
            case let .regSuccess(model):
                
                return .run { send in
                    try await realmRepo.upsertWorkSpace(response: model)
                    
                    await send(.realmRegSuccess)
                    
                } catch: { error, send in
                    print(error)
                    await send(.errorMessage("저장중 오류가 발생하였습니다."))
                }
                
            case .realmRegSuccess:
                return .run { send in
                    await send(.successMessage("저장 되었습니다."))
                }
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .successMessage(message):
                state.successMessage = message
                
            case .alertSuccessTapped:
                return .run { send in
                    await self.dismiss()
                    await send(.ifNeedSuccessTrigger)
                }
                
            default :
                break
            }
            
            return .none
        }
        
    }
}
