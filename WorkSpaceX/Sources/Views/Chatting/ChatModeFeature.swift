//
//  ChatModeFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChatModeFeature {
    
    enum FileCountCase {
        case none
        case one
        case two
        case three
        case four
        case five
        
        enum fileType {
            case image
            case PDF
            case ZIP
        }
    }
    
    @ObservableState
    struct State {
        let model: ChatModeEntity
        
    }
    
    enum Action {
        case onAppear
        
        case delegate(Delegate)
        
        case profileClicked
        
        enum Delegate {
            case selectedProfile(WorkSpaceMemberEntity)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                break
            case .profileClicked:
                switch state.model.isMe {
                case .me:
                    break
                case let .other(member):
                    return .run { send in
                        await send(.delegate(.selectedProfile(member)))
                    }
                }
                
            default:
                break
            }
            
            return .none
        }
    }
    
}
