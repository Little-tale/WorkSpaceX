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
        case profileEmpty
        case empty
        case loading
        case success(Data)
        case failure
        case urlImage(URL)
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case empty
        case profileEmpty
        case loading
        case success(Data)
        case ifURL(URL?)
        case ifURLString(String?)
        case fail
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .empty:
                state.imageState = .empty

            case .loading:
                state.imageState = .loading

            case let .success(data):
                state.imageState = .success(data)
    
            case .fail:
                state.errorMessage = "이미지를 불러오지 못했습니다."
            
            case let .ifURL(url):
                if let url {
                    state.imageState = .urlImage(url)
                } else {
                    state.imageState = .empty
                }
            case let .ifURLString(urlString):
                guard let urlString,
                      let url = URL(string: urlString) else {
                    print("이미지 URL 받기 실패")
                    state.imageState = .empty
                    break
                }
                state.imageState = .urlImage(url)
                
            case .profileEmpty:
                state.imageState = .profileEmpty
            default :
                break
            }
            return .none
        }
    }
    
}
