//
//  AddMemberFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AddMemberFeature {
    
    @ObservableState
    struct State: Equatable {
        var id = UUID()
        
        var currentChannelID: String
        
        var currentEmail = ""
        var regButtonState = false
        var errorMessage: String? = nil
        var successMessage: String? = nil
        var showPrograssView = false
        var showValidText = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case regButtonTapped
        
        // 내부용
        case catchTextValid
        
        // Alert State
        case errorMessage(String?)
        case successMessage(String?)
        // 상위뷰 관찰
        case dismissButtonTapped
        case alertSuccessTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            
            switch action {
            
            case .binding:
                let email = state.currentEmail
                let result = TextValid.TextValidate(email, caseOf: .email)
                break
                
            default:
                break
            }
            
            return .none
        }
        
    }
}
