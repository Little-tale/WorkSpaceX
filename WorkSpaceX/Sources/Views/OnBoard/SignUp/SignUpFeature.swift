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
        
        var focusField: Field?
        
        // 요구가 변경되어 추가 유효성 여부 상관없이 값 입력시 버튼 활성화
        
        var emailValid: textValidation = .isEmpty
        
        var nickNameValid: textValidation = .isEmpty
        
        var contactValid: textValidation = .isEmpty
        
        var passwordValid: textValidation = .isEmpty
        
        var passwordCheck: Bool = false
        
        var lastButtonState: Bool = false
        
        var duplicateButtonState: Bool = false
        
        var presentationText: String? = nil
        
        var alReadyEmailCheck: Bool = false
        
        var scopeAndColorChange: Field?  = nil
       
    }
    enum Field: Hashable, CaseIterable {
        case email, nickname, contact, password, passwordConfirm
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
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
        
        // 최종 버튼 클릭시
        case lastButtonTapped
        
        // 최종 회원가입 로직 시작
        case userRegEvent(UserRegEntityModel)
        
        // focus
        case focusTextField(Field)
        
        // login완료를 부모에게 전달
        case onlyUseParentsUserEntity(UserEntity)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var reposiory
    
    var body: some ReducerOf<Self> {
        BindingReducer()
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
                print(checkPass)
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
                
                state.user.contact = clean.formatPhoneNumber
                
                return .run { send in
                    await send(.lastButtonState)
                }
                
            case .lastButtonState:
                let result = !state.user.email.isEmpty && !state.user.nickName.isEmpty &&
                !state.user.password.isEmpty &&
                !state.user.passwordConfirmaion.isEmpty
                state.lastButtonState = result
                print(state.user.email.isEmpty)
                print(state.user.nickName.isEmpty)
                print(state.user.password.isEmpty)
                print(state.user.passwordConfirmaion.isEmpty)
                
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
                    
                    let result = try await reposiory.chaeckEmail(email)
                    
                    await send(.checkEmailSuccess)
                    await send(.returnView("중복되지 않았어요"))
                    
//                    switch result {
//                    case .success:
//                        
//                    case .failure(let errorCase):
//                        switch errorCase {
//                        case .httpError(let error):
//                            await send(.returnView(error))
//                        case .commonError(let error):
//                            await send(.returnView(error.message))
//                        case .customError(let error):
//                            await send(.returnView(error))
//                        case .unknownError:
//                            await send(.returnView("알수없음"))
//                        }
//                    }
                } catch: { error, send in
                    if let error = error as? EmailValidError {
                        if error.ifDevelopError {
                            await send(.returnView("이메일 검사중 에러가 발생하였습니다!"))
                        } else {
                            await send(.returnView(error.message))
                        }
                    }
                }
            case .checkEmailSuccess:
                state.alReadyEmailCheck = true
                return .none
                
            case .lastButtonTapped:
                /*
                 우선순위 이메일 > 닉네임 > 전화번호 > 비밀번호 > (네트워크 후 ) -> 이미 가입됬는가? 에러가 발생했는가?
                 */
                guard case .match = state.emailValid else {
                    return .run { send in
                        await send(.returnView("이메일 형식을 확인해 주세요"))
                        await send(.focusTextField(.email))
                    }
                }
                
                guard state.alReadyEmailCheck else {
                    return .run { send in
                       await send(.returnView("이메일 중복 확인을 진행해 주세요"))
                        await send(.focusTextField(.email))
                    }
                }
                guard case .match = state.nickNameValid else {
                    return .run { send in
                        await send(.returnView("닉네임은 1글자 이상 30글자 이내로 부탁드려요."))
                        await send(.focusTextField(.nickname))
                    }
                }
                guard case .match = state.contactValid else {
                    return .run { send in
                        await send(.returnView("잘못된 전화번호 형식입니다."))
                        await send(.focusTextField(.contact))
                    }
                }
                guard case .match = state.passwordValid else {
                    return .run { send in
                        await send(.returnView("비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."))
                        await send(.focusTextField(.password))
                    }
                }
                
                if state.user.passwordConfirmaion != state.user.password{
                    return .run { send in
                        await send(.returnView("작성하신 비밀번호가 일치하지 않습니다. "))
                        await send(.focusTextField(.passwordConfirm))
                    }
                }
                let user = state.user
                return .run { send in
                    await send(.userRegEvent(user))
                }
            case let .userRegEvent(user):
                
                return .run { send in
                    let result = try await reposiory.requestUserReg(user)
                    await send(.onlyUseParentsUserEntity(result))
                } catch : { error, send in
                    if let error = error as? UserRegAPIError {
                        if error.ifDevelopError {
                            await send(.returnView("유저 등록중 에러가 발생하였습니다."))
                        } else {
                            await send(.returnView(error.message))
                        }
                    }
                }
            case let .focusTextField(field):
                state.scopeAndColorChange = field
                state.focusField = field
                
                return .none
                
            case .binding:
                return .none
                
            case .onlyUseParentsUserEntity:
                return .none
            }
        }
    }
}
