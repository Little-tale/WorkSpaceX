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
    
    
}
