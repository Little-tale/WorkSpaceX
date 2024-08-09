//
//  ProfileInfoFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import Foundation
import ComposableArchitecture
import UserNotifications

/*
 결제 처리 관련 수정 완료 -> 정상적으로 결제처리가 됩니다.
 */
@Reducer
struct ProfileInfoFeature {

    @ObservableState
    struct State: Equatable {
        var id: UUID
        var userType: UserType
        var errorMessage: String? = nil
        var notiMessage: String? = nil
        
        var tabBarHidden: Bool
        
        var userEntity: UserInfoEntity? = nil
        var otherEntity: WorkSpaceMemberEntity? = nil
        
        var imagePick = CustomImagePickFeature.State()
        var showImagePicker = false
        
        var image: Data? = nil
        var popUpViewState: String? = nil
        var logOutViewState: logOutState? = nil
        var progress: Bool = false
        
        var ifNeedOnAppear: Bool = true
        
        var notificationBool: Bool = false
        
        var navigationTitle: String = ""
    }
    
    enum UserType: Equatable {
        case me(userID: String)
        case other(userID: String)
    }
    
    struct logOutState: Equatable {
        let title = "로그아웃"
        let message = "로그아웃시 메시지 기록은 삭제됩니다."
        let cancel = "취소"
        let action = "로그아웃"
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        case imagePickFeature(CustomImagePickFeature.Action)
        case showImagePicker
        case imagePick(Bool)
        
        case imagePickerData(Data?)
        case imageRegRequest(Data)
        case realmUpdate(UserEntity)
        
        case profileInfoRequestMe(userID: String)
        
        case profileInfoRequestOther(userID: String)
        
        case resultToMe(UserInfoEntity)
        case resultToOther(WorkSpaceMemberEntity)
        
        case errorMessage(String?)
        
        case selectedMECase(MyProfileViewType)
        case popUpViewState(String?)
        case logOutViewState(logOutState?)
        case logOutConfirm
        case currentNotificationState
        case catchToCurrentNoti(UNAuthorizationStatus)
        /// 딜레이
        case progressBool(Bool)
        
        case showProgressView(Bool)
        
        case notificationBool(Bool)
        
        case notiMessage(String?)
        
        case notifiGoSetting
        
        enum Delegate {
            case moveToNickNameChange(UserInfoEntity)
            case moveToContactChange(UserInfoEntity)
            case moveToOnBoardingView
            case moveToCoinShop(Int)
        }
        
        case parentAction(ParentAction)
        
        enum ParentAction {
            case updateID(UserType)
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workRepo
    
    @Dependency(\.userDomainRepository) var userRepo
    
    @Dependency(\.realmRepository) var realmRepo
    
    @Dependency(\.notificationStateManager) var notiManager
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.imagePick, action: \.imagePickFeature) {
            CustomImagePickFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.tabBarHidden {
                    state.navigationTitle = "설정"
                } else {
                    state.navigationTitle = "내 정보 수정"
                }
                
                let ifNeed = state.ifNeedOnAppear
                switch state.userType {
                case let .me(userID):
                    return .run { send in
                        if ifNeed {
                            await send(.imagePickFeature(.profileEmpty))
                        }
                        await send(.currentNotificationState)
                        await send(.profileInfoRequestMe(userID: userID))
                    }
                case let .other(userID):
                    return .run { send in
                        await send(.profileInfoRequestOther(userID: userID))
                    }
                }
            case .profileInfoRequestMe(_):
                state.ifNeedOnAppear = false
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
            case let .profileInfoRequestOther(userID):
                return .run { send in
                    let result = try await userRepo.otherUserProfileRequest(userID)
                    await send(.resultToOther(result))
                }
                
            case let .resultToMe(model):
                state.userEntity = model
                if let image = model.profileImage {
                    return .run { send in
                        await send(.imagePickFeature(.ifURLString(image)))
                    }
                }
                
            case let .resultToOther(model):
                state.otherEntity = model
    
            case let .imagePick(bool):
                state.showImagePicker = bool
                
            case .showImagePicker:
                state.showImagePicker = true
                
            case let .notificationBool(bool):
                state.notificationBool = bool
                
            case let .imagePickerData(data):
                
                if let data {
                    state.image = data
                    return .run { send in
                        await send(.imageRegRequest(data))
                        await send(.imagePickFeature(.success(data)))
                    }
                }
                
            case let .selectedMECase(meCaseOf):
                
                guard let user = state.userEntity else {
                    break
                }
                
                switch meCaseOf {
                case .myCoinInfo:
                // 코인 결제 기능 추가하여야 함.
                    
                    if let model = state.userEntity {
                        return .run { send in
                            await send(.delegate(.moveToCoinShop(model.sesacCoin)))
                        }
                    }
                    
                case .nickName:
                    return .run { send in
                        await send(.delegate(.moveToNickNameChange(user)))
                    }
                case .contact:
                    return .run { send in
                        await send(.delegate(.moveToContactChange(user)))
                    }
                    
                case .email:
                    break // 선택되지 않습니다.
                    
                case .connectedSocial:
                    break // 선택되지 않습니다.
                    
                case .notificationState:
                    break
                    
                case .logout:
                    return .run { send in
                        await send(.logOutViewState(.init()))
                    }
                }
                
            case let .logOutViewState(model):
                state.logOutViewState = model
                
            case let .imageRegRequest(data):
                return .run { send in
                    await send(.showProgressView(true))
                    
                    let result = try await userRepo.profileImageEdit(
                        data
                    )
                    await send(.showProgressView(false))
                    
                    await send(.realmUpdate(result)) // 프로필은 다른뷰에서도 업데이트 가능
                } catch: { error, send in
                    if let error = error as? UserEditAPIError{
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                            await send(.imagePickFeature(.profileEmpty))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
            case let .showProgressView(bool):
                state.progress = bool
//                return .run { send in
//                    try await Task.sleep(for: .seconds(1))
//                    await send(.progressBool(bool))
//                }
                
            case let .progressBool(bool):
                state.progress = bool
                
            case let .realmUpdate(model):
                let image = model.profileImage
                return .run { send in
                    if let image {
                        await send(.imagePickFeature(.ifURLString(image)))
                    }
                    try await realmRepo.upsertUserModel(response: model)
                    await send(.popUpViewState("이미지가 변경 되었어요!"))
                } catch: { error, _ in
                    print(error)
                }
                // 로그아웃
            case .logOutConfirm :
                state.logOutViewState = nil
                state.progress = true
                return .run { send in
                    try await realmRepo.logout()
                    try await Task.sleep(for: .seconds(1))
                    await send(.delegate(.moveToOnBoardingView))
                } catch: {error, _ in
                    print(error)
                }
                
            case let .parentAction(.updateID(caseOf)):
                state.userType = caseOf
                
            case .currentNotificationState:
                return .run { send in
                    for await result in await notiManager.notificationSettingsStream() {
                        await send(.catchToCurrentNoti(result))
                    }
    
                }
            case let .catchToCurrentNoti(notiCase):
                switch notiCase {
                case .notDetermined: // 허용 하지 않음
                    state.notificationBool = false
                    break
                case .denied: // 거부
                    state.notificationBool = false
                case .authorized, .provisional, .ephemeral: // 허용
                    state.notificationBool = true
                @unknown default:
                    break
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
        case notificationState
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
            case .notificationState:
                return "알림 설정"
            case .logout:
                return "로그아웃"
            }
        }
        func detail(from model: UserInfoEntity) -> String? {
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
            case .logout, .notificationState:
                return nil
            }
        }
        
        static var topSectionCases: [MyProfileViewType] {
            return [.myCoinInfo, .nickName, .contact]
        }
        
        static var notifications: [MyProfileViewType] {
            return [.notificationState]
        }
        
        static var bottomSectionCases: [MyProfileViewType] {
            return [.email, .connectedSocial, .logout]
        }
        
        static var emailLoginBottomSection: [MyProfileViewType] {
            return [.email, .logout]
        }
    }
    
}

extension ProfileInfoFeature {
    
    enum OtherViewType {
        case nickName
        case email
        
        var title: String {
            switch self {
            case .nickName:
                return "닉네임"
            case .email:
                return "이메일"
            }
        }
        
        func detail(_ model: WorkSpaceMemberEntity) -> String {
            switch self {
            case .nickName:
                return model.nickName
            case .email:
                return model.email
            }
        }
        
        static var section: [OtherViewType] {
            return [.nickName, .email]
        }
    }
    
}
