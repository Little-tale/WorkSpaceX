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
    }
    
    enum Field {
        case email
        case password
    }
    
    @Dependency(\.dismiss) var dismiss
    
    
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
            case .binding:
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
