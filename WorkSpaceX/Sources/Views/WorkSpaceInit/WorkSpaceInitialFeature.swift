//
//  WorkSpaceInitialFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//
import UIKit.UIImage
import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceInitialFeature {
    
    @ObservableState
    struct State: Equatable {
        var imagePick = CustomImagePickFeature.State()
        
        let workSpaceNameFieldType = WorkSpaceNameFieldType()
        let workSpaceExplainType = WorkSpaceExplainType()
        let navigationTitle = "워크스페이스 생성"
        
        var showImagePicker = false
        
        var workSpaceName = ""
        var workSpaceIntroduce = ""
        var regButtonState = false
        var image: Data? = nil
        
        var errorMessage: String? = nil
        var successMessage: String? = nil
        
        var showProgressView = false
        
        var logOutAlertState: AlertState<Action.Alert>?
    }
    
    struct WorkSpaceNameFieldType: Equatable {
        let headerTitle = "워크스페이스 이름"
        let placeHolderTitle = "워크스페이스 이름을 입력하세요 (필수)"
    }
    
    struct WorkSpaceExplainType: Equatable {
        let headerTitle = "워크스페이스 설명"
        let placeHolderTitle = "워크스페이스 설명를 설명하세요 (옵션)"
    }
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickFeature.Action)
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        case error(String)
        case regSuccess(WorkSpaceEntity)
        case regFaileHandler(MakeWorkSpaceAPIError)
        case goRootCheck
        case showLogoutAlert
        case alert(PresentationAction<Alert>)
        @CasePathable
        enum Alert {
            case confirmButtonTapped
        }
        
        case realmRegSuccess(workSpaceID: String)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.workspaceDomainRepository) var repository
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                
                workSpaceNameValid(state: &state)
            case .showImagePicker:
                state.imagePick.imageState = .loading
                state.showImagePicker = true
                
            case .imagePickerData(let ifData):
        
                pickDataTester(state: &state, imageData: ifData)
            case .regButtonTapped:
                state.showProgressView = true

                let description = makeDescription(state: &state)
                guard let workSpaceRequest = makeImageRequest(state: &state, description: description) else {
                    return .run { send in
                        await send(.error("이미지 작업중 문제가 발생했습니다."))
                    }
                }

                return .run { [request = workSpaceRequest ] send in
                    print(request)
                    let result = try await repository.regWorkSpaceRequest(request)
                    UserDefaultsManager.workSpaceSelectedID = result.workSpaceID
                    await send(.regSuccess(result))
                    
                } catch : { error, send in
                    if let error = error as? MakeWorkSpaceAPIError {
                        await send(.regFaileHandler(error))
                    } else {
                        print(error)
                    }
                }
                
            case .dismissButtonTapped:
                
                return .run { send in
                    await self.dismiss()
                }
            case .error(let errorMessage):
                state.errorMessage = errorMessage
           
                
            case .regSuccess(let model):
                
                return .run { send in
                    try await realmRepo.upsertWorkSpace(response: model)
                    await send(.realmRegSuccess(workSpaceID: model.workSpaceID))
                } catch: { error, send in
                    print(error)
                }
                
                
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
                
            case .alert(.presented(.confirmButtonTapped)):
                
                return .run{ send in
                    await send(.goRootCheck)
                }
                
            case .regFaileHandler(let error):
                state.showProgressView = false
                
                if error.ifReFreshDead {
                    return .run { send in
                        await send(.showLogoutAlert)
                    }
                } else {
                    if error.ifDevelopError {
                        print(error)
                    } else {
                        return .run{ send in
                            await send(.error(error.message))
                        }
                    }
                }
                
            case .alert(.dismiss):
                return .run{ send in
                    await send (.goRootCheck)
                }
                
            default:
                break
            }
            return .none
        }
        
    }
}

extension WorkSpaceInitialFeature {
    
    private func workSpaceNameValid(state: inout State) {
        let text = state.workSpaceName
        state.regButtonState = !text.isEmpty
    }
    
    private func pickDataTester(state: inout State, imageData: Data?) {
        if let imageData {
            state.imagePick.imageState = .success(imageData)
            state.image = imageData
        } else {
            state.imagePick.imageState = .empty
        }
    }
    
    private func makeDescription(state: inout State) -> String? {
        var description: String?
        
        if state.workSpaceIntroduce != "" {
            description = state.workSpaceIntroduce
        }
        
        return description
    }
    
    private func makeImageRequest(state: inout State, description: String? ) -> NewWorkSpaceRequest? {
        var request: NewWorkSpaceRequest
        
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
                return nil
            }
            request = NewWorkSpaceRequest(
                name: state.workSpaceName,
                description: description,
                image: data
            )
        }
        
        return request
    }
    
}
