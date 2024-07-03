//
//  ProfileInfoFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileInfoFeature {

    @ObservableState
    struct State: Equatable {
        var id: UUID
        var userType: UserType
        var errorMessage: String? = nil
        var userEntity: UserEntity? = nil
        
        var imagePick = CustomImagePickPeature.State()
        var showImagePicker = false
        
        var image: Data? = nil
        
    }
    
    enum UserType: Equatable {
        case me(userID: String)
        case other(userID: String)
    }
    
    enum Action {
        case onAppaer
        case delegate(Delegate)
        
        case imagePickFeature(CustomImagePickPeature.Action)
        case showImagePicker
        case imagePick(Bool)
        
        case imagePickerData(Data?)
        
        case profilInfoReqeustMe(userID: String)
        
        case profilInfoRequestOther(userID: String)
        
        case resultToMe(UserEntity)
        
        case errorMessage(String?)
        
        enum Delegate {
            
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workRepo
    
    @Dependency(\.userDomainRepository) var userRepo
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickPeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppaer:
                switch state.userType {
                case let .me(userID):
                    return .run { send in
                        await send(.profilInfoReqeustMe(userID: userID))
                    }
                case let .other(userID):
                    break
                }
            case .profilInfoReqeustMe(_):
                return .run { send in
                    let result = try await userRepo.myProfile()
                    
                    await send(.resultToMe(result))
                    
                } catch: { error, send in
                    if let error = error as? MyProfileAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error) }
                    } else {
                        print(error)
                    }
                }
                
            case let .resultToMe(model):
                state.userEntity = model
                
            case let .imagePick(bool):
                state.showImagePicker = bool
                
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
                
            default:
                break
            }
            return .none
        }
    }
}
