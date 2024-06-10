//
//  WorkSpaceInitalFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceInitalFeature {
    
    @ObservableState
    struct State {
        var imagePick = CustomImagePickPeature.State()
        var showImagePicker = false
        var workSpaceName = ""
        var workSpaceIntroduce = ""
        var regButtonState = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                let text = state.workSpaceName
                state.regButtonState = !text.isEmpty
                return .none
                
            case .imagePickFeature:
                return .none
                
            case .showImagePicker:
                state.imagePick.imageState = .loading
                state.showImagePicker = true
                return .none
                
            case .imagePickerData(let ifData):
                if let ifData {
                    state.imagePick.imageState = .success(ifData)
                } else {
                    state.imagePick.imageState = .empty
                }
                return .none
                
            case .regButtonTapped:
                print("눌름")
                
                
                return .none
            }
    
        }
        
    }
}
