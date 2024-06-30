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
        let id: UUID
        let workSpaceID: String
        let channelEntity: ChanelEntity
        var isOwner: Bool
        
        var channelName: String = "#"
        var channelIntro: String = ""
        var usersCount: String = "(0)"
        var users: [WorkSpaceMembersEntity] = []
        
        var errorMessage: String? = nil
        
        var alertCaseOf: AlertCase?
        
        enum AlertCase: Equatable {
            case exitChannelToOwner
            case exitChneel
            case noMemberButOwnerChangeTry
            
            // Error
            case errorEvent(String)
            
            var title: String {
                switch self {
                case .exitChannelToOwner, .exitChneel:
                    return "채널에서 나가기"
                case .noMemberButOwnerChangeTry:
                    return "채널 관리자 변경 불가"
                case .errorEvent:
                    return "Error"
                }
            }
            
            var message: String {
                switch self {
                case .exitChannelToOwner:
                    return "회원님은 채널 관리자 입니다.\n채널 관리자를 변경후 나가실수 있어요!"
                case .exitChneel:
                    return "나가시면 채널 목록이 삭제 됩니다."
                case .noMemberButOwnerChangeTry:
                    return "채널 멤버가 없어 관리자 변경을 할 수 없습니다."
                case let .errorEvent(message):
                    return message
                }
            }
            
            var alertMode: AlertMode {
                switch self {
                case .exitChannelToOwner:
                    return .onlyCheck
                case .exitChneel:
                    return .cancelWith
                case .noMemberButOwnerChangeTry:
                    return .onlyCheck
                case .errorEvent:
                    return .onlyCheck
                }
            }
            
            var alertActionTitle: String {
                switch self {
                case .exitChannelToOwner, .errorEvent, .noMemberButOwnerChangeTry:
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
        case realmChannelsUpdate([ChanelEntity])
        
        case alertAction(State.AlertCase)
        
        case netWorkResult(ChanelEntity)
        
        case exitChannel
        
        // 채널 수정 클릭
        case channelEditClicked
        // 채널 관리자 변경 클릭
        case channelOwnerChangeRequest
        
        case delegate(Delegate)
        
        case errorMessage(String?)
        
        enum Delegate {
            case exitConfirm
            
            case channelEditClicked(model: ChanelEntity, workSpaceID: String)
            
            case channelOwnerChangeReqeust(model: ChanelEntity, workSpaceID: String)
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.channelName = "# " + state.channelEntity.name
                
                state.channelIntro = state.channelEntity.description
                
                state.users = state.channelEntity.users
                let count = state.channelEntity.users.count
                state.usersCount = "(\(count))"
                
                let workSpaceID = state.workSpaceID
                let cheenlID = state.channelEntity.channelId
                
                
                
                return .run { send in
                    let result = try await workSpaceRepo.channelInfoRequest(
                        workSpaceID,
                        cheenlID
                    )
                    await send(.netWorkResult(result))
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .netWorkResult(model):
                
                state.channelName = "# " + model.name
                
                state.channelIntro = model.description
                
                state.users = model.users
                
                let count = state.channelEntity.users.count
                
                state.usersCount = "(\(count))"
                if let userID = UserDefaultsManager.userID {
                    state.isOwner = model.owner_id == userID
                }
                
            case .channelExitTry:
                print("채널 나가기 시도")
                let isOwner = state.isOwner
                
                return .run { send in
                    await send(.alertCaseOf(isOwner ? .exitChannelToOwner : .exitChneel))
                }
                
            case let .alertCaseOf(alertCase):
                print("얼렛 케이스 발동 \(alertCase)")
                state.alertCaseOf = alertCase
                
            case let .alertAction(caseOf):
                print("얼렛 액션 발동 \(caseOf)")
                switch caseOf {
                case .exitChannelToOwner, .errorEvent, .noMemberButOwnerChangeTry:
                    break
                case .exitChneel:
                    return .run { send in
                        await send(.exitChannel)
                    }
                }
                
            case .exitChannel:
                let workSpaceId = state.workSpaceID
                let channelID = state.channelEntity.channelId
                return .run { send in
                    let results = try await workSpaceRepo.exitChannel(
                        workSpaceId,
                        channelID
                    )
                    WSXSocketManager.shared.stopAndRemoveSocket()
//                    await send(.delegate(.exitConfirm))
                    await send(.realmChannelsUpdate(results))
                } catch: { error, send in
                    if let error = error as? WorkSpaceExitChannelAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            await send(.alertAction(.errorEvent(error.message)))
                        } else {
                            print("에러 ->",error)
                        }
                    } else {
                        print("에러 ->",error)
                    }
                }
                
            case let .realmChannelsUpdate(models):
//                return .run { send in
//                    await send(.delegate(.exitConfirm))
//                }
                return .run { send in
                    try await realmRepo.upserWorkSpaceChannels(
                        channels: models
                    )
                    await send(.delegate(.exitConfirm))
                }
            case .channelEditClicked:
                let channel = state.channelEntity
                let workSpaceID = state.workSpaceID
                return .run { send in
                    await send(.delegate(.channelEditClicked(model: channel, workSpaceID: workSpaceID)))
                }
                
            case .channelOwnerChangeRequest:
                let channel = state.channelEntity
                let bool = channel.users.count <= 1
                let workSpace = state.workSpaceID
                if bool {
                    return .run { send in
                        await send(.alertAction(.noMemberButOwnerChangeTry))
                    }
                } else {
                    return .run { send in
                        await send(.delegate(.channelOwnerChangeReqeust(model: channel, workSpaceID: workSpace)))
                    }
                }
            default:
                break
            }
            
            return .none
        }
    }
    
}
