//
//  ProfileInfoEditFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileInfoEditFeature {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        let editType: EditType
        var model: UserInfoEntity
        var currentText: String = ""
        var buttonState = false
        
        var errorMessage: String? = nil
        var successTrigger: Bool = false
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        case duplicateTester
        case currentText(String)
        case textTester
        case regButtonTapped
        
        case updateRealm(UserEntity)
        
        case regSuccess
        case lastTrigger
        
        case errorMessage(String?)
        case successTrigger(Bool)
        enum Delegate {
            case regSuccess
        }
    }
    
    enum EditType {
        case nickName
        case contact
        
        var navigationTitle: String {
            switch self {
            case .nickName:
                return "닉네임 수정"
            case .contact:
                return "연락처 수정"
            }
        }
        
        var placeHolder: String {
            switch self {
            case .nickName:
                return "닉네임을 입력해 주세요"
            case .contact:
                return "전화번호를 입력해 주세요"
            }
        }
    }
    
    @Dependency(\.userDomainRepository) var userRepo
    @Dependency(\.realmRepository) var realmRepo
    var body: some ReducerOf<Self> {
    
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                let model = state.model
                switch state.editType {
                case .nickName:
                    state.currentText = model.nickname
                case .contact:
                    state.currentText = model.phone ?? ""
                }
                return .run { send in
                    await send(.textTester)
                }
                
            case let .currentText(text):
                state.currentText = text
                return .run { send in
                    await send(.textTester)
                }
                
            case .textTester:
                let text = state.currentText
                var bool: Bool
                switch state.editType {
                case .nickName:
                    let result = TextValid.TextValidate(text, caseOf: .nickName)
                    bool = result == .match
                    state.buttonState = bool
                    
                case .contact:
                    let clean = text.filter { $0.isNumber }
                    let result = TextValid.TextValidate(clean, caseOf: .phoneNumber)
                    state.currentText = clean.formatPhoneNumber
                    bool = result == .match
                    state.buttonState = bool
                }
                if bool {
                    return .run { send in
                        await send(.duplicateTester)
                    }
                }
    
            case .duplicateTester:
                switch state.editType {
                case .nickName:
                    let nickName = state.model.nickname
                    
                    state.buttonState = nickName != state.currentText
                case .contact:
                    let contact = state.model.phone ?? ""
                    state.buttonState = contact != state.currentText
                }
            case .regButtonTapped:
                let current = state.currentText
                let model = state.model
                state.buttonState = false
                switch state.editType {
                case .nickName:
                    return .run { send in
                        let result = try await userRepo.profileInfoEdit(current, model.phone ?? "")
                        await send(.updateRealm(result))
                    } catch: { error, send in
                        if let error = error as? UserEditAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
                            } else {
                                print(error)
                            }
                        } else {
                            print(error)
                        }
                    }
                case .contact:
                    return .run { send in
                        let result = try await userRepo.profileInfoEdit(model.nickname, current)
                        await send(.updateRealm(result))
                    } catch: { error, send in
                        if let error = error as? UserEditAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
                            } else {
                                print(error)
                            }
                        } else {
                            print(error)
                        }
                    }
                }
                
            case let .updateRealm(model):
                return .run { @MainActor send in
                    let result = try await  realmRepo.upsertUserModel(response: model)
                    if result != nil {
                        send(.regSuccess)
                    } else {
                        send(.errorMessage("저장중 문제가 발생했어요"))
                    }
                }
            case .regSuccess:
                state.buttonState = false
                return .run { send in
                    await send(.successTrigger(true))
                }
            case let .successTrigger(bool):
                state.successTrigger = bool
                
            case .lastTrigger:
                return .run { send in
                    await send(.delegate(.regSuccess))
                }
            case let .errorMessage(message):
                state.buttonState = message == nil
                state.errorMessage = message
                
            default:
                break
            }
            return .none
        }
    }
}
