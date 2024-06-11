//
//  WorkSpaceInitalFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//
import UIKit.UIImage
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
        var image: Data? = nil
        var errorMessage: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        case error(String)
        case regSuccess(WorkSpaceEntity)
        case regFaileHandler(WorkSpaceDomainError)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.workspaceDomainRepository) var repository
    
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
                    state.image = ifData
                } else {
                    state.imagePick.imageState = .empty
                }
                
                return .none
                
            case .regButtonTapped:
                
                var description: String?
                
                var request: NewWorkSpaceRequest
                
                if state.workSpaceIntroduce != "" {
                    description = state.workSpaceIntroduce
                }
                
                if let image = state.image {
                    request = NewWorkSpaceRequest(
                        name: state.workSpaceName,
                        description: description,
                        image: image
                    )
                } else {
                    guard let data = WSXImage.logoUIImage.imageZipLimit(
                        zipRate: 1
                    ) else {
                        return .run { send in
                            await send(.error("이미지 작업중 문제가 발생했습니다."))
                        }
                    }
                    request = NewWorkSpaceRequest(
                        name: state.workSpaceName,
                        description: description,
                        image: data
                    )
                }
                
                return .run { [request = request] send in
                    print(request)
                    let result = await repository.regWorkSpaceReqeust(request)
                    switch result {
                    case let .success(model):
                        await send(.regSuccess(model))
                    case let .failure( error):
                        await send(.regFaileHandler(error))
                    }
                }
            case .dismissButtonTapped:
                
                return .run { send in
                    await self.dismiss()
                }
                
            case .error(let errorMessage):
                state.errorMessage = errorMessage
                return .none
            case .regSuccess(let model):
                print("success 이여야!")
                dump(model)
                return .none
            case .regFaileHandler(let error):
                print("에러가 나긴함?",error)
                switch error {
                case let .commonError(error):
                    return .run{ send in
                        await send(.error(error.message))
                    }
                case .makeWoekSpaceError:
                    if !error.ifDevelopError {
                        return .run{ send in
                            await send(.error(error.message))
                        }
                    } else {
                        print(error)
                    }
                
                default :
                    break
                }
                return .none
            }
        }
        
    }
}
