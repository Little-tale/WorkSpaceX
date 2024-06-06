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
        
        var user = UserRegEntityModel()
        
        var passwordConfirm = ""
        
        // 요구가 변경되어 추가 유효성 여부 상관없이 값 입력시 버튼 활성화
        
        var emailValid: textValidation = .isEmpty
        
        var nickNameValid: textValidation = .isEmpty
        
        var contactValid: textValidation = .isEmpty
        
        var passwordValid: textValidation = .isEmpty
        
        var passwordCheck: Bool = false
        
        var testButtonState: Bool = false
        
        var duplicateButtonState: Bool = false
        
        var presentationText: String? = nil
        
        var alReadyEmailCheck: Bool = false
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
        
        // 중복 확인 버튼을 클릭시
        case duplicateButtonTapped
        
        // iOS 17 버그로 인한
        case iOS17BugNumberChecked(String)
        
        // toast
        case returnView(String?)
        
        // 중복 체크 통신 시작 액션
        case checkEmail
        // 중복체크 완료 액션
        case checkEmailSuccess
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var reposiory
    
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
                state.duplicateButtonState = !email.isEmpty
                state.alReadyEmailCheck = false
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
                let result = state.user.email.isEmpty ||  state.user.nickName.isEmpty ||
                state.user.password.isEmpty ||
                state.user.passwordConfirmaion.isEmpty
                state.testButtonState = !result
                return .none
            case .duplicateButtonTapped:
                if case .match = state.emailValid{
                    if state.alReadyEmailCheck != false {
                        return .run { send in
                            await send(.returnView("이미 중복확인 처리된 이메일 입니다."))
                        }
                    } else {
                        return .run { send in
                            await send(.checkEmail)
                        }
                    }
                } else {
                    state.presentationText = "이메일 형식이 올바르지 않습니다."
                    return .none
                }
            
            case .returnView(let text):
                state.presentationText = text
                return .none
                
            case .checkEmail:
                let email = state.user.email
                return .run { send in
                    do {
                        try await reposiory.chaeckEmail(email)
                        await send(.checkEmailSuccess)
                        await send(.returnView("중복되지 않았어요"))
                    } catch let error as APIError {
                        if case .customError(let errorCase) = error {
                            print(UserDomainError.emailValid(errorCase).message)
                        }
                    } catch {// 1차 시도 알수없는 에러 즉 Router 구성 잘못됨.
                        await send(.returnView(APIError.Unkonwn))
                    }
                }
            case .checkEmailSuccess:
                state.alReadyEmailCheck = true
                return .none
            }
            // 버튼 누를시 로 변경
            /*
             let result = state.contactValid == .match && state.emailValid == .match && state.nickNameValid == .match && state.passwordValid == .match && state.passwordCheck == true
             
             state.testButtonState = result
             print("emailValid \(state.emailValid)")
             print("contactValid \(state.contactValid)")
             print("nickNameValid \(state.nickNameValid)")
             print("passwordValid \(state.passwordValid)")
             print("passwordCheck \(state.passwordCheck)")
             */
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
