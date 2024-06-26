//
//  ChatChannelSettingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import Foundation
import ComposableArchitecture


@Reducer
struct ChatChannelSettingFeature {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        let channelEntity: ChanelEntity
        var isOwner: Bool
        
        var channelName: String = "#"
        var channelIntro: String = ""
        var usersCount: String = "(0)"
        var users: [WorkSpaceMembersEntity] = []
        
        var alertCaseOf: AlertCase?
        
        enum AlertCase: Equatable {
            case exitChannelToOwner
            case exitChneel
            
            var title: String {
                switch self {
                case .exitChannelToOwner, .exitChneel:
                    return "채널에서 나가기"
                }
            }
            
            var message: String {
                switch self {
                case .exitChannelToOwner:
                    return "회원님은 채널 관리자 입니다.\n채널 관리자를 변경후 나가실수 있어요!"
                case .exitChneel:
                    return "나가시면 채널 목록이 삭제 됩니다."
                }
            }
            
            var alertMode: AlertMode {
                switch self {
                case .exitChannelToOwner:
                    return .onlyCheck
                case .exitChneel:
                    return .cancelWith
                }
            }
            
            var alertActionTitle: String {
                switch self {
                case .exitChannelToOwner:
                    return "확인"
                case .exitChneel:
                    return "나가기"
                }
            }
        }
    }
    
    
    enum Action {
        case onAppear
        case channelExitTry
        case alertCaseOf(State.AlertCase?)
        
        
        case alertAction(State.AlertCase)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.channelName = "# " + state.channelEntity.name
                
                state.channelIntro = state.channelEntity.description
                
                state.users = state.channelEntity.users
                let count = state.channelEntity.users.count
                state.usersCount = "(\(count))"
                
            case .channelExitTry:
                print("채널 나가기 시도")
                let isOwner = state.isOwner
                
                return .run { send in
                    await send(.alertCaseOf(isOwner ? .exitChannelToOwner : .exitChneel))
                }
                
            case let .alertCaseOf(alertCase):
                print("얼렛 케이스 발동 \(alertCase)")
                state.alertCaseOf = alertCase
                
            default:
                break
            }
            
            return .none
        }
    }
    
}
