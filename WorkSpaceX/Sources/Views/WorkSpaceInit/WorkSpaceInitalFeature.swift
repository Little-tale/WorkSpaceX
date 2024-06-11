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
        var successMessage: String? = nil
        var showPrograssView = false
        var logOutAlertState: AlertState<Action.Alert>?
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
        case goRootCheck
        case showLogoutAlert
        case alert(PresentationAction<Alert>)
        @CasePathable
        enum Alert {
            case confirmButtonTapped
        }
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
                state.showPrograssView = true
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
            case .goRootCheck: // 상위뷰 관찰
                return .none
                
            case .error(let errorMessage):
                state.errorMessage = errorMessage
                return .none
                
            case .regSuccess(let model):
                print("success 이여야!")
                dump(model)
                state.showPrograssView = false
                state.successMessage = "등록 완료 되었습니다."
                return .none
                
            case .showLogoutAlert:
                state.logOutAlertState = AlertState {
                    TextState("로그아웃 되었습니다.")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmButtonTapped) {
                        TextState("확인")
                    }
                } message: {
                    TextState("다시 로그인 하시고 이용하여 주세요!")
                }
                return .none
                
            case .alert(.presented(.confirmButtonTapped)):
                
                return .run{ send in
                    await send(.goRootCheck)
                }
                
            case .regFaileHandler(let error):
                state.showPrograssView = false
                switch error {
                    
                case let .commonError(error):
                    if case .refreshDead = error {
                        return .run { send in
                            await send(.showLogoutAlert)
                        }
                    }
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
                
            case .alert(.dismiss):
                return .none
            }
        }
        
    }
}

