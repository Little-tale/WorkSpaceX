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
        
        let channelEntity: ChanelEntity
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
                
            case .onAppear:
                let model = state.channelEntity
                state.channelName = model.name
                state.channelIntro = model.description
                
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
                
                break
                
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
