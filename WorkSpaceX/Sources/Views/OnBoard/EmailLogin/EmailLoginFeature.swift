//
//  EmailLoginFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EmailLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var buttonState: Bool = false
        var alertMessage: String? = nil
        let emailNavTitle = "이메일 로그인"
        var focusField: Field? = nil
        
        var confirm: Bool = false
        var loginBottomMessage: String? = nil
        var logining: Bool = false
    }
    
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dismiss
        case timerStart(String)
        case timerStop
        case loginButtonTapped
        case errorHandler(EmailLoginAPIError)
        case loginSuccess(UserEntity)
    }
    
    enum Field: Hashable {
        case email
        case password
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDomainRepository) var repository
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        core()
    }
}
extension EmailLoginFeature {
    
    private func core() -> some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
            case .binding(\.email):
                updateButton(state: &state)
    
            case .binding(\.password):
                updateButton(state: &state)
                
            case .timerStart(let message):
                state.loginBottomMessage = message
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.timerStop)
                }
            case .timerStop:
                state.loginBottomMessage = nil
                
            case .loginButtonTapped:
                
                return loginValid(state: &state)
            case .errorHandler(let error):
                state.logining = false
                if !error.ifDevelopError {
                    state.alertMessage = error.message
                    return .run { send in
                        await send(.timerStart(error.message))
                    }
                } else {
                    print(error)
                }
                
            default:
                break
            }
            return .none
        }
        
    }
}

extension EmailLoginFeature {
    
    private func updateButton(state: inout State) {
        let email = state.email
        let password = state.password
        let result = checkButtonState(email: email, password: password)
        state.buttonState = result
    }
    
    private func loginValid(state: inout State) -> Effect<Action> {
        let email = state.email
        let password = state.password
        state.logining = true
        return .run { send in
           let result = try await repository.requestEmailLogin((email,password))
            print("이메일 로그인 성공시 출력")
            UserDefaultsManager.accessToken = result.token?.accessToken
            UserDefaultsManager.refreshToken = result.token?.refreshToken
            print("이메일 \(result)")
            await send(.loginSuccess(result))
        } catch: { error, send in
            if let error = error as? EmailLoginAPIError {
                await send(.errorHandler(error))
            } else {
                print("이메일 로그인 에러",error)
                await send(.timerStart("로그인중 문제가 발생헀습니다."))
            }
        }
            .throttle(id: Field.email ,for: 1, scheduler: RunLoop.main, latest: false)
    }
}


extension EmailLoginFeature {
    
    private func checkButtonState(email: String, password: String) -> Bool{
        let result = TextValid.TextValidate(email, caseOf: .email)
        let password = TextValid.TextValidate(password, caseOf: .password)
        
        guard case .match = result else {
            return false
        }
        
        guard case .match = password else {
            return false
        }
        
        return true
    }
    
}
