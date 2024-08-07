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
            case channelDelegteTry
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
                case .channelDelegteTry:
                    return "채널 삭제"
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
                case .channelDelegteTry:
                    return "정말 이 채널을 삭제 하시겠습니까?\n 삭제시 멤버/채팅 등 채널내의 모든 정보가 삭제되며 복구 하실수 없습니다."
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
                    
                case .channelDelegteTry:
                    return .cancelWith
                }
            }
            
            var alertActionTitle: String {
                switch self {
                case .exitChannelToOwner, .errorEvent, .noMemberButOwnerChangeTry:
                    return "확인"
                case .exitChneel:
                    return "나가기"
                case .channelDelegteTry:
                    return "삭제"
                }
            }
        }
        
        var channelOwnerChanged: Bool = false
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
        // 채널 삭제 클릭
        case channelDeleteClicked
        case channelDeleteStart
        
        case delegate(Delegate)
        
        case parentsAction(ParentAction)
        case channelOwnerChanged(Bool)
        case errorMessage(String?)
        
        enum Delegate {
            case exitConfirm
            
            case channelEditClicked(model: ChanelEntity, workSpaceID: String)
            
            case channelOwnerChangeReqeust(model: ChanelEntity, workSpaceID: String)
            
            case channelDeleteConfirm
        }
        enum ParentAction {
            case successOwnerChange
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension ChatChannelSettingFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                return onAppearSideEffect(state: &state)
    
            case let .netWorkResult(model):
                networkResultSideEffect(state: &state, model: model)
            
            case .channelExitTry:
                print("채널 나가기 시도")
                let isOwner = state.isOwner
                
                return .run { send in
                    await send(.alertCaseOf(isOwner ? .exitChannelToOwner : .exitChneel))
                }
                
            case let .alertCaseOf(alertCase):
                print("얼렛 케이스 발동 \(String(describing: alertCase) )")
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
                case .channelDelegteTry:
                    return .run { send in
                        await send(.channelDeleteStart)
                    }
                }
                
            case .exitChannel:
                return exitChannelSideEffect(state: &state)
                
            case let .realmChannelsUpdate(models):
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
            case .channelDeleteClicked:
                return .run { send in
                    await send(.alertCaseOf(.channelDelegteTry))
                }
                
            case .channelDeleteStart:
                return channelDeleteSideEffect(state: &state)
                
            case .parentsAction(.successOwnerChange):

                return .run { send in
                    await send(.channelOwnerChanged(true))
                }
            case let .channelOwnerChanged(bool):
                state.channelOwnerChanged = bool
                
            default:
                break
            }
            
            return .none
        }
    }
}



extension ChatChannelSettingFeature {
    
    private func onAppearSideEffect(state: inout State) -> Effect<Action> {
        setFirstSetting(state: &state)

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
                if !error.ifDevelopError {
                    await send(.errorMessage(error.message))
                } else {
                    print(error)
                }
            } else {
                print(error)
            }
        }
    }
    
    
    private func setFirstSetting(state: inout State)  {
        state.channelName = "# " + state.channelEntity.name
        state.channelIntro = state.channelEntity.description
        state.users = state.channelEntity.users
        
        let count = state.channelEntity.users.count
        state.usersCount = "(\(count))"
    }
    
    private func networkResultSideEffect(state: inout State, model: ChanelEntity) {
        state.channelName = "# " + model.name
        
        state.channelIntro = model.description
        
        state.users = model.users
        
        let count = state.channelEntity.users.count
        
        state.usersCount = "(\(count))"
        if let userID = UserDefaultsManager.userID {
            state.isOwner = model.owner_id == userID
        }
    }
    
    private func channelDeleteSideEffect(state: inout State) -> Effect<Action> {
        let workSpaceID = state.workSpaceID
        let channelID = state.channelEntity.channelId
        return .run { send in
            
            try await workSpaceRepo.channelDeleteRequest(workSpaceID, channelID)
            await WorkSpaceReader.shared.observeChannelStop(channelID)
            
            try await realmRepo.removeChannel(channelID)
            
            await send(.delegate(.channelDeleteConfirm))
            
        } catch: { error, send in
            if let error = error as? ChannelDeleteAPIError {
                if !error.ifDevelopError {
                    await send(.errorMessage(error.message))
                } else {
                    print(error)
                }
            }
        }
    }
    
    
    private func exitChannelSideEffect(state: inout State) -> Effect<Action> {
        let workSpaceId = state.workSpaceID
        let channelID = state.channelEntity.channelId
        return .run { send in
            let results = try await workSpaceRepo.exitChannel(
                workSpaceId,
                channelID
            )
            WSXSocketManager.shared.stopAndRemoveSocket()

            await send(.realmChannelsUpdate(results))
        } catch: { error, send in
            if let error = error as? WorkSpaceExitChannelAPIError {
                if !error.ifDevelopError {
                    await send(.errorMessage(error.message))
                } else {
                    print(error)
                }
            } else {
                print("에러 ->",error)
            }
        }
    }
}
