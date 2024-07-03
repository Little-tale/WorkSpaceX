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
        
        case selectedMECase(MyProfileViewType)
        
        enum Delegate {
            case moveToNickNameChange(UserEntity)
            case moveToContackChange(UserEntity)
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
                print("모델스",model)
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
                
            case let .selectedMECase(meCaseOf):
                
                guard let user = state.userEntity else {
                    break
                }
                
                switch meCaseOf {
                case .myCoinInfo:
                   break // 코인 결제 기능 추가하여야 함.
                case .nickName:
                    return .run { send in
                        await send(.delegate(.moveToNickNameChange(user)))
                    }
                case .contact:
                    return .run { send in
                        await send(.delegate(.moveToContackChange(user)))
                    }
                case .email:
                    break // 선택되지 않습니다.
                case .connectedSocial:
                    break // 선택되지 않습니다.
                case .logout:
                    break // 로그아웃 기능 구현해야함
                }
                
            default:
                break
            }
            return .none
        }
    }
}


extension ProfileInfoFeature {
    /// 본인일 경우
    enum MyProfileViewType: CaseIterable {
        
        case myCoinInfo
        case nickName
        case contact
        case email
        case connectedSocial
        case logout
        
        var title: String {
            switch self {
            case .myCoinInfo:
                return "내 새싹 코인"
            case .nickName:
                return "닉네임"
            case .contact:
                return "연락처"
            case .email:
                return "이메일"
            case .connectedSocial:
                return "연결된 소셜 계정"
            case .logout:
                return "로그아웃"
            }
        }
        func detail(from model: UserEntity) -> String? {
            switch self {
            case .myCoinInfo:
                // 코인 정보를 받으셔야함.
                return String(model.sesacCoin)
            case .nickName:
                return model.nickname
            case .contact:
                return model.phone
            case .email:
                return model.email
            case .connectedSocial:
                return model.provider
            case .logout:
                return nil
            }
        }
        
        static var topSectionCases: [MyProfileViewType] {
            return [.myCoinInfo, .nickName, .contact]
        }
        
        static var bottomSectionCases: [MyProfileViewType] {
            return [.email, .connectedSocial, .logout]
        }
    }
    
}
