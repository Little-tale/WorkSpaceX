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
    }
    
    enum Action {
        case imagePickFeature(CustomImagePickPeature.Action)
        
    }
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            switch action {
            case .imagePickFeature:
                return .none
            }
            
        }
        
    }
}
