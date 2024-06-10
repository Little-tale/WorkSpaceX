//
//  RootFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//


import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    
    struct State {
        var currentLoginState: loginState = .logout
    }
    
    enum loginState {
        case login
        case logout
        case firstLogin
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {state, action in
            switch action {
            case .onAppear :
                UserDefaultsManager.accessToken
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
}
