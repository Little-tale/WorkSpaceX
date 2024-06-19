//
//  WorkSpaceChannelAddFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import UIKit.UIImage
import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceChannelAddFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        let workSpaceId: String
        
        var imagePick = CustomImagePickPeature.State()
        var showImagePicker = false
        var channelName = ""
        var channelIntro = ""
        var regButtonState = false
        var image: Data? = nil
        var errorMessage: String? = nil
        var successMessage: String? = nil
        var showPrograssView = false
    }
    
    enum Action: BindableAction {
    
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        
        case errorMessage(String?)
        case successMessage(String?)
        
        case realmRegSuccess
        
        case ifNeedSuccessTrigger
        case alertSuccessTapped
    }
    
    @Dependency(\.workspaceDomainRepository) var repository
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            
            switch action {
                
            case .showImagePicker:
                state.showImagePicker = true
                
            case let .imagePickerData(data):
                
                if let data {
                    state.image = data
                    return .run { send in
                        await send(.imagePickFeature(.success(data)))
                    }
                } else {
                    return .run { send in
                        await send(.imagePickFeature(.empty))
                    }
                }
                
            case .binding:
                state.regButtonState = state.channelName != ""
                
            case .regButtonTapped:
                let id = state.workSpaceId
                print("채널 등록시 아이디:",id)
                let title = state.channelName
                let intro = state.channelIntro
                let data = state.image
                
                let newChannel = NewWorkSpaceRequest(
                    name: title,
                    description: intro,
                    image: data
                )
                
                return .run { send in
                    let result = try await repository.regWorkSpaceChannel(
                        newChannel,
                        id
                    )
                    try await realmRepo.upsertToWorkSpaceChannelAppend(workSpaceID: id, chanel: result)
                    
                    await send(.realmRegSuccess)
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceMakeChannelAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                            return
                        }
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error) }
                    } else {
                        print(error)
                    }
                }
                
            case .realmRegSuccess:
                return .run { send in
                    await send(.successMessage("저장 되었습니다."))
                }
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .successMessage(message):
                state.successMessage = message
                
            case .alertSuccessTapped:
                return .run { send in
                    
                    await send(.ifNeedSuccessTrigger)
                }
                
            default :
                break
            }
            
            return .none
        }
        
    }
}
