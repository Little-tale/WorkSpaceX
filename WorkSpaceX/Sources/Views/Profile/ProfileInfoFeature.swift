//
//  ProfileInfoFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileInfoFeature {

    @ObservableState
    struct State: Equatable {
        var id: UUID
        var userType: UserType
    }
    
    enum UserType: Equatable {
        case me(userID: String)
        case other(userID: String)
    }
    
    enum Action {
        case onAppaer
        
        case delegate(Delegate)
        
        enum Delegate {
            
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppaer:
                switch state.userType {
                case let .me(userID):
                    break
                case let .other(userID):
                    break
                }
            default:
                break
            }
            return .none
        }
    }
}
