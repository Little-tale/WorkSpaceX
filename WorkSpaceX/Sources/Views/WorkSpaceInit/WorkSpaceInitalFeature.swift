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
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        case showImagePicker
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                
                return .none
                
            case .imagePickFeature:
       
                return .none
            case .showImagePicker:
                
                state.showImagePicker = true
                
                return .none
            }
    
        }
        
    }
}
