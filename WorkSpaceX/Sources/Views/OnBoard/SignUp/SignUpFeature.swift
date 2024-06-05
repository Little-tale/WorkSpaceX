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
    }
    
    enum Action {
        case cancelButtonTapped
        case emailChanged(String)
        case nicknameChanged(String)
        case contactChanged(String)
        case passwordChanged(String)
        case passwordConfirmationChanged(String)
        
        case sideNumberEffect(String)
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
                return .none
            case let .nicknameChanged(name):
                let result = TextValid.TextValidate(name, caseOf: .nickName)
                state.nickNameValid = result
                state.user.nickName = name
                
                return .none
            case let .contactChanged(phones):
                print("사용자 \(phones)")
                let clean = phones.filter { $0.isNumber }
                
                let result = TextValid.TextValidate(phones, caseOf: .phoneNumber)

                
//                state.user.contact = phones
                print("클린 \(clean)")
                state.user.contact = clean
                state.contactValid = result
                
                return .none

            case let .passwordChanged(password):
                state.user.password = password
                return .none
            case let .passwordConfirmationChanged(checkPass):
                
                state.user.passwordConfirmaion = checkPass
                
                return .none
                
            case let .sideNumberEffect(text) :
                
               
                
                
//                let result = formatPhoneNumber(clean)
//                print("SSSS",clean)
////                state.user.contact = result
//                state.user.contact = result
                return .none
            }
        }
    }
}

extension SignUpFeature {
    func formatPhoneNumber(_ number: String) -> String {
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
