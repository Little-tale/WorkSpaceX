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
        var confirm: Bool = false
        var alertMessage: String? = nil
        var loginBottomMessge: String? = nil
        var buttonState: Bool = false
        var focusField: Field? = nil
        
        var logining: Bool = false
        
        let emailNavTitle = "이메일 로그인"
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dismiss
        case timerStart(String)
        case timerStop
        case loginButtonTapped
        case errorHandeler(EmailLoginAPIError)
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
        
        Reduce {state, action in
            switch action {
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
            case .binding(\.email):
                let email = state.email
                let password = state.password
                let result = checkButtonState(email: email, password: password)
                state.buttonState = result
                return .none
            case .binding(\.password):
                let email = state.email
                let password = state.password
                let result = checkButtonState(email: email, password: password)
                state.buttonState = result
                return .none
            case .timerStart(let message):
                state.loginBottomMessge = message
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.timerStop)
                }
            case .timerStop:
                state.loginBottomMessge = nil
                return .none
            case .loginButtonTapped:
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
                        await send(.errorHandeler(error))
                    } else {
                        print("이메일 로그인 에러",error)
                        await send(.timerStart("로그인중 문제가 발생헀습니다."))
                    }
                }
                    .throttle(id: Field.email ,for: 1, scheduler: RunLoop.main, latest: false)
                
            case .binding:
                return .none
                
            case .errorHandeler(let error):
                state.logining = false
                if !error.ifDevelopError {
                    state.alertMessage = error.message
                    return .run { send in
                        await send(.timerStart(error.message))
                    }
                } else {
                    print(error)
                }
                return .none
            case .loginSuccess:
                return .none
            }
        }
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
