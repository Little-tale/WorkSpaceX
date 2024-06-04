//
//  SignUpFreature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import ComposableArchitecture

@Reducer
struct SignUpFreature {
    
    @ObservableState
    struct State: Equatable {
        var email = ""
        var nickName = ""
        var contact = ""
        var password = ""
        var passwordConfirmaion = ""
    }
    
    enum Action {
        case cancelButtonTapped
        
        case emailChanged(String)
        case nicknameChanged(String)
        case phoneNumberChanged(String)
        case passwordChanged(String)
        case passwordRepeatChanged(String)
        
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { send in
                    await self.dismiss()
                }
                
            case let .emailChanged(text):
                
                return .none
            case let .nicknameChanged(text):
                
                return .none
            case let .phoneNumberChanged(text):
                
                return .none
            case let .passwordChanged(text):
                
                return .none
            case let .passwordRepeatChanged(text):
                
                return .none
            }
        }
    }
    
}
