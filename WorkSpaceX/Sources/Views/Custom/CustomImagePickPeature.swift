//
//  CustomImagePickPeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CustomImagePickPeature {
    
    @ObservableState
    struct State: Equatable {
        var imageState: ImagePickState = .empty
        var errorMessage: String? = nil
    }
    enum ImagePickState: Equatable {
        case empty
        case loading
        case success(Data)
        case failure
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case empty
        case loading
        case success(Data)
        case fail
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .empty:
                state.imageState = .empty
                return .none
            case .loading:
                state.imageState = .loading
                return .none
            case let .success(data):
                state.imageState = .success(data)
                return .none
            case .fail:
                state.errorMessage = "이미지를 불러오지 못했습니다."
                return .none
            case .binding:
                return .none
            }
        }
    }
    
}
