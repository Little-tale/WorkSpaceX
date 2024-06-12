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
    
    enum Field {
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
                return .run { send in
                   let result = try await repository.requestEmailLogin((email,password))
                } catch: { error, send in
                    if let error = error as? EmailLoginAPIError {
                        await send(.errorHandeler(error))
                    } else {
                        await send(.timerStart("로그인중 문제가 발생헀습니다."))
                    }
                }
                
            case .binding:
                return .none
            case .errorHandeler(let error):
                if error.ifDevelopError {
                    state.alertMessage = error.message
                } else {
                    print(error)
                }
                return .none
            case .loginSuccess(let user): // 상위뷰가 지켜볼것.
                print("로그인 성공 \(user)")
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
    
//    private func errorHandelForLogin(error: UserDomainError) -> String? {
//        switch error {
//        case .commonError(let common):
//            if !common.ifDevelopError {
//                return common.message
//            } else {
//                print("개발자 잘못 \(common.message)")
//            }
//        case .emailLoginError:
//            if !error.ifDevelopError {
//                return error.message
//            } else {
//                print("개발자 잘못 \(error.message)")
//            }
//        default:
//            break
//        }
//        return nil
//    }
    
}
