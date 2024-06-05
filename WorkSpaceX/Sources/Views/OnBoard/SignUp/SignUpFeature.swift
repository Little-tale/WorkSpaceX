//
//  SignUpFreature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture

@Reducer
struct SignUpFeature {
    
    @ObservableState
    struct State: Equatable {
        
        var user = UserRegModel()
        
        var passwordConfirm = ""
        
        var emailValid: textValidation = .isEmpty
        
        var nickNameValid: textValidation = .isEmpty
        
        var contactValid: textValidation = .isEmpty
        
        var passwordValid: textValidation = .isEmpty
        
        var passwordCheck: Bool = false
        
        var testButtonState: Bool = false
        
        var duplicateButtonState: Bool = false
    }
    
    enum Action {
        case cancelButtonTapped
        case emailChanged(String)
        case nicknameChanged(String)
        case contactChanged(String)
        case passwordChanged(String)
        case passwordConfirmationChanged(String)
        
        // 최종 버튼 상태를 반영
        case lastButtonState
        // iOS 17 버그로 인한
        case iOS17BugNumberChecked(String)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { send in
                    await self.dismiss()
                }
                
            case let .emailChanged(email):
                let result = TextValid.TextValidate(email, caseOf: .email)
                state.emailValid = result
                state.user.email = email
                state.duplicateButtonState = result == .match
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case let .nicknameChanged(name):
                let result = TextValid.TextValidate(name, caseOf: .nickName)
                state.nickNameValid = result
                state.user.nickName = name
                
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case let .contactChanged(phones):
                
                state.user.contact = phones
                
                return .run { send in
                    await send(.iOS17BugNumberChecked(phones))
                    await send(.lastButtonState)
                }
                
            case let .passwordChanged(password):
                let result = TextValid.TextValidate(password, caseOf: .password)
                state.user.password = password
                state.passwordValid = result
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case let .passwordConfirmationChanged(checkPass):
                
                state.user.passwordConfirmaion = checkPass
                let before = state.user.password
                let ifconfirm = state.user.passwordConfirmaion
                
                state.passwordCheck = before == ifconfirm
                
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case let .iOS17BugNumberChecked(checkNumber):
                
                let clean = checkNumber.filter { $0.isNumber }
                
                let result = TextValid.TextValidate(clean, caseOf: .phoneNumber)
                
                state.contactValid = result
                
                state.user.contact = formatPhoneNumber(clean)
                
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case .lastButtonState:
                let result = state.contactValid == .match && state.emailValid == .match && state.nickNameValid == .match && state.passwordValid == .match && state.passwordCheck == true
                
                state.testButtonState = result
                print("emailValid \(state.emailValid)")
                print("contactValid \(state.contactValid)")
                print("nickNameValid \(state.nickNameValid)")
                print("passwordValid \(state.passwordValid)")
                print("passwordCheck \(state.passwordCheck)")
                return .none
            }
        }
    }
}

extension SignUpFeature {
    
    private func formatPhoneNumber(_ number: String) -> String {
        var result = ""
        var mask = "XXX-XXX-XXXX"
        if number.count == 11 {
            mask = "XXX-XXXX-XXXX"
        }
        var index = number.startIndex
        
        for change in mask where index < number.endIndex {
            if change == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(change)
            }
        }
        print(result)
        return result
    }
}
