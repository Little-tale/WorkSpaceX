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
    }
    
    enum Action: BindableAction {
        case getModel(WorkSpaceRealmModel)
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        case error(String)
        case regSuccess(WorkSpaceEntity)
        case regFaileHandler(MakeWorkSpaceAPIError)
        case goRootCheck
        case realmRegSuccess
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.workspaceDomainRepository) var repository
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            
            switch action {
                
            case let .getModel(model):
                
                print("받아옴, \(model)")
                state.workSpaceName = model.workSpaceName
                state.workSpaceIntroduce = model.introduce ?? ""
                
                let imageUrl = model.coverImage
                
                return .run { send in
                    await send(.imagePickFeature(.ifURLString(imageUrl)))
                }
                
            case .dismissButtonTapped:
                return .run { send in
                    await self.dismiss()
                }
                
            default :
                break
            }
            return .none
        }
        
    }
}
