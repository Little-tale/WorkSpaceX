//
//  ChannelEditFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChannelEditFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID = UUID()
        
        var channelEntity: ChanelEntity
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
        
        case onAppear
        
        case binding(BindingAction<State>)
        case imagePickFeature(CustomImagePickPeature.Action)
        
        case showImagePicker
        case imagePickerData(Data?)
        case regButtonTapped
        case dismissButtonTapped
        
        case realmRegStart(ChanelEntity)
        
        case errorMessage(String?)
        case successMessage(String?)
        
        case realmRegSuccess
        
        case delegate(Delegate)
        
        enum Delegate {
            case successChannel(ChanelEntity)
        }
        case alertSuccessTapped
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                print("채널 편집 ->")
                let model = state.channelEntity
                state.channelName = model.name
                state.channelIntro = model.description
                if let image = model.coverImage {
                    return .run { send in
                        await send(.imagePickFeature(.ifURLString(image)))
                    }
                }
                
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
                let bool = state.channelName != state.channelEntity.name
                state.regButtonState = state.channelName != "" && bool
                
            case .regButtonTapped:
                let workSpaceId = state.workSpaceId
                let channelID = state.channelEntity.channelId
                
                let reqeust = ModifyWorkSpaceDTORequest(
                    name: state.channelName,
                    description: state.channelIntro,
                    image: state.image
                )
                
                return .run { send in
                    
                    let result = try await workSpaceRepo.editToChannel(
                        workSpaceId,
                        channelID,
                        reqeust
                    )
                    
                    await send(.realmRegStart(result))
                } catch: { error, send in
                    if let error = error as? ChannelEditAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .realmRegStart(model):
                state.channelEntity = model
                return .run { @MainActor send in
                    let result = try await realmRepo.upserWorkSpaceChannel(
                        channel: model,
                        ifRealm: nil
                    )
                    if result == nil {
                        send(.errorMessage("등록중 문제가 발생했습니다."))
                    } else {
                        send(.successMessage("등록이 완료 되었습니다."))
                        
                    }
                } catch: { error, send in
                    print(error)
                }
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .successMessage(message):
                state.successMessage = message
                
            case .alertSuccessTapped:
                let successModel = state.channelEntity
                return .run { send in
                    await send(.delegate(.successChannel(successModel)))
                }
                
            default :
                break
            }
            
            return .none
        }
        
    }
}
